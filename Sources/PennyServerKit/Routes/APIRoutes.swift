import Foundation
import Hummingbird
import PennyCore

/// Everything the API handlers need. Injected so tests can pin the clock and swap the ledger.
public struct APIContext: Sendable {
    public let household: Household
    public let ledger: any LedgerRepository
    /// The period transaction dates are labelled against ("Today" vs "Sep 23").
    public let period: @Sendable () -> BudgetPeriod
    public let now: @Sendable () -> Date

    public init(
        household: Household, ledger: any LedgerRepository,
        period: @escaping @Sendable () -> BudgetPeriod, now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.household = household
        self.ledger = ledger
        self.period = period
        self.now = now
    }
}

/// `GET /api/summary`, `GET|PATCH /api/transactions`, `POST /api/household/settle`.
struct APIRoutes {
    static let maxBodySize = 64 * 1024

    let context: APIContext

    func register(on router: Router<some RequestContext>) {
        let api = router.group("api")
        api.get("summary") { _, _ in try summary() }
        api.get("transactions") { request, _ in try await listTransactions(request) }
        api.patch("transactions") { request, _ in try await recategorize(request) }
        api.post("household/settle") { request, _ in try await settle(request) }
    }

    /// Month-at-a-glance numbers for the Home screen and the web Overview.
    func summary() throws -> Response {
        try Responses.json(API.Summary(household: context.household))
    }

    func listTransactions(_ request: Request) async throws -> Response {
        let parameters = request.uri.queryParameters
        let query: TransactionQuery
        do throws(ValidationError) {
            query = try TransactionQuery(
                category: parameters["category"].map(String.init),
                limit: parameters["limit"].map(String.init)
            )
        } catch {
            return try Responses.error(error, status: .badRequest)
        }
        let period = context.period()
        let transactions = try await context.ledger.transactions(matching: query)
        return try Responses.json(API.TransactionList(transactions: transactions.map { API.TransactionResource($0, period: period) }))
    }

    /// Fix a category from the review queue; the web and iPhone apps both call this.
    func recategorize(_ request: Request) async throws -> Response {
        let data = try await body(of: request)
        var fields: JSONFields
        do throws(ValidationError) {
            fields = try JSONFields(data)
        } catch {
            return try Responses.error(error, status: .unprocessableContent)
        }
        let id = fields.string("id")
        let category = fields.enumeration("category", as: CategoryKey.self)
        guard let id, let category, fields.errors.isEmpty else {
            return try Responses.error(fields.errors, status: .unprocessableContent)
        }
        guard let updated = try await context.ledger.recategorize(transactionID: id, to: category) else {
            return try Responses.error("Transaction not found", status: .notFound)
        }
        return try Responses.json(API.TransactionEnvelope(transaction: API.TransactionResource(updated, period: context.period())))
    }

    func settle(_ request: Request) async throws -> Response {
        let data = try await body(of: request)
        var fields: JSONFields
        do throws(ValidationError) {
            fields = try JSONFields(data)
        } catch {
            return try Responses.error(error, status: .unprocessableContent)
        }
        let from = fields.enumeration("from", as: MemberID.self)
        let to = fields.enumeration("to", as: MemberID.self)
        let amount = fields.positiveCents("amount")
        let method = fields.enumeration("method", as: SettlementMethod.self, default: .transfer)
        guard let from, let to, let amount, let method, fields.errors.isEmpty else {
            return try Responses.error(fields.errors, status: .unprocessableContent)
        }
        let result: SettlementResult
        do throws(SettlementError) {
            result = try SettlementService.settle(
                SettleUpRequest(from: from, to: to, amount: amount, method: method),
                against: context.household.settleUpBalance,
                recordedAt: context.now().ISO8601Format()
            )
        } catch let .invalidFields(errors) {
            return try Responses.error(errors, status: .unprocessableContent)
        } catch {
            return try Responses.error(error.message, status: .unprocessableContent)
        }
        return try Responses.json(result)
    }

    private func body(of request: Request) async throws -> Data {
        let buffer = try await request.body.collect(upTo: Self.maxBodySize)
        return Data(buffer.readableBytesView)
    }
}
