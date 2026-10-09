import Foundation
import Hummingbird
import HummingbirdTesting
import PennyCore
import Testing
@testable import PennyServerKit

private func makeApp() -> some ApplicationProtocol {
    let household = Household.sample
    let fixedNow = Date(timeIntervalSince1970: 1_790_000_000)
    let api = APIContext(
        household: household, ledger: InMemoryLedger(transactions: household.transactions),
        period: { household.period }, now: { fixedNow }
    )
    let staticDirectory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("static").path
    return Application(router: PennyApplication.router(api: api, staticDirectory: staticDirectory))
}

private func json(_ response: TestResponse) throws -> [String: Any] {
    let object = try JSONSerialization.jsonObject(with: Data(buffer: response.body))
    return try #require(object as? [String: Any])
}

private func body(_ text: String) -> ByteBuffer { ByteBuffer(string: text) }

@Suite("API")
struct APITests {
    @Test func healthCheck() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/healthz", method: .get) { response in
                #expect(response.status == .ok)
                #expect(String(buffer: response.body) == #"{"status":"ok"}"#)
            }
        }
    }

    @Test func summary() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/summary", method: .get) { response in
                #expect(response.status == .ok)
                #expect(response.headers[.contentType] == "application/json; charset=utf-8")
                let summary = try JSONDecoder().decode(API.Summary.self, from: Data(buffer: response.body))
                #expect(summary == API.Summary(household: .sample))
                #expect(summary.household.owedToMaya == 109)
            }
        }
    }

    @Test func listAndFilterTransactions() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/transactions?limit=3", method: .get) { response in
                let list = try JSONDecoder().decode(API.TransactionList.self, from: Data(buffer: response.body))
                #expect(list.transactions.map(\.id) == ["t1", "t2", "t3"])
                #expect(list.transactions[0].date == "Today")
            }
            try await client.execute(uri: "/api/transactions?category=pets", method: .get) { response in
                let list = try JSONDecoder().decode(API.TransactionList.self, from: Data(buffer: response.body))
                #expect(list.transactions.map(\.merchant) == ["Linden Pet Supply"])
                #expect(list.transactions[0].date == "Sep 23")
            }
        }
    }

    @Test func invalidQueryIs400WithFieldErrors() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/transactions?category=rent&limit=500", method: .get) { response in
                #expect(response.status == .badRequest)
                let errors = try #require(try json(response)["error"] as? [String: [String]])
                #expect(errors["limit"] == ["Number must be less than or equal to 200"])
                #expect(errors["category"]?.count == 1)
            }
        }
    }

    @Test func recategorizePersistsAcrossRequests() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/transactions", method: .patch, body: body(#"{"id":"t3","category":"dining"}"#)) { response in
                #expect(response.status == .ok)
                let envelope = try JSONDecoder().decode(API.TransactionEnvelope.self, from: Data(buffer: response.body))
                #expect(envelope.transaction.category == .dining)
            }
            try await client.execute(uri: "/api/transactions?category=dining", method: .get) { response in
                let list = try JSONDecoder().decode(API.TransactionList.self, from: Data(buffer: response.body))
                #expect(Set(list.transactions.map(\.id)) == ["t2", "t3"])
            }
        }
    }

    @Test(arguments: [
        (#"{"category":"home"}"#, "id", "Required"),
        (#"{"id":"","category":"home"}"#, "id", "String must contain at least 1 character(s)"),
        (#"{"id":7,"category":"home"}"#, "id", "Expected string, received number"),
        (#"{"id":"t1","category":"rent"}"#, "category", "Invalid enum value. Expected 'groceries' | 'dining' | 'home' | 'transport' | 'shopping' | 'fun' | 'pets' | 'health' | 'coffee', received 'rent'"),
        ("not json", "body", "Expected a JSON object"),
        ("null", "body", "Expected object, received null"),
    ])
    func recategorizeValidation(payload: String, field: String, message: String) async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/transactions", method: .patch, body: body(payload)) { response in
                #expect(response.status == .unprocessableContent)
                let errors = try #require(try json(response)["error"] as? [String: [String]])
                #expect(errors[field] == [message])
            }
        }
    }

    @Test func recategorizeUnknownTransactionIs404() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/transactions", method: .patch, body: body(#"{"id":"t99","category":"home"}"#)) { response in
                #expect(response.status == .notFound)
                let message = try json(response)["error"] as? String
                #expect(message == "Transaction not found")
            }
        }
    }

    @Test func settleUpFullAndPartial() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/household/settle", method: .post, body: body(#"{"from":"J","to":"M","amount":109}"#)) { response in
                #expect(response.status == .ok)
                let result = try JSONDecoder().decode(SettlementResult.self, from: Data(buffer: response.body))
                #expect(result.balance.settled)
                #expect(result.settlement.method == .transfer)
                #expect(result.settlement.recordedAt == "2026-09-21T14:13:20Z")
            }
            try await client.execute(uri: "/api/household/settle", method: .post, body: body(#"{"from":"J","to":"M","amount":9.5,"method":"cash"}"#)) { response in
                let result = try JSONDecoder().decode(SettlementResult.self, from: Data(buffer: response.body))
                #expect(result.balance.remaining == 99.5)
                #expect(result.settlement.method == .cash)
            }
        }
    }

    @Test(arguments: [
        (#"{"from":"J","to":"M","amount":-1}"#, "amount", "Number must be greater than 0"),
        (#"{"from":"J","to":"M","amount":1.005}"#, "amount", "Number must be a multiple of 0.01"),
        (#"{"from":"J","to":"M","amount":"5"}"#, "amount", "Expected number, received string"),
        (#"{"from":"X","to":"M","amount":5}"#, "from", "Invalid enum value. Expected 'M' | 'J', received 'X'"),
        (#"{"from":"J","to":"M","amount":5,"method":"check"}"#, "method", "Invalid enum value. Expected 'transfer' | 'cash' | 'other', received 'check'"),
        (#"{"from":"J","amount":5}"#, "to", "Required"),
    ])
    func settleValidation(payload: String, field: String, message: String) async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/household/settle", method: .post, body: body(payload)) { response in
                #expect(response.status == .unprocessableContent)
                let errors = try #require(try json(response)["error"] as? [String: [String]])
                #expect(errors[field] == [message])
            }
        }
    }

    @Test func settleWithOneMemberTwiceIsRejected() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/api/household/settle", method: .post, body: body(#"{"from":"M","to":"M","amount":5}"#)) { response in
                #expect(response.status == .unprocessableContent)
                let message = try json(response)["error"] as? String
                #expect(message == "Choose two different members")
            }
        }
    }
}

@Suite("Site and static files")
struct SiteRouteTests {
    @Test(arguments: ["/", "/features", "/household", "/pricing", "/app"])
    func pagesRender(path: String) async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: path, method: .get) { response in
                #expect(response.status == .ok)
                #expect(response.headers[.contentType] == "text/html; charset=utf-8")
                #expect(response.headers[.xContentTypeOptions] == "nosniff")
                #expect(String(buffer: response.body).hasPrefix("<!DOCTYPE html>"))
            }
        }
    }

    @Test func unknownPageIsAnHTML404() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/does-not-exist", method: .get) { response in
                #expect(response.status == .notFound)
                #expect(String(buffer: response.body).contains("Nothing filed"))
            }
            try await client.execute(uri: "/api/unknown", method: .get) { response in
                #expect(response.status == .notFound)
                #expect(String(buffer: response.body) == #"{"error":"Not found"}"#)
            }
        }
    }

    @Test func staticAssetsAreServedWithCaching() async throws {
        try await makeApp().test(.router) { client in
            try await client.execute(uri: "/css/site.css", method: .get) { response in
                #expect(response.status == .ok)
                #expect(response.headers[.cacheControl] == "public, max-age=3600")
                #expect(String(buffer: response.body).contains("--font-serif"))
            }
            try await client.execute(uri: "/images/goal-home.webp", method: .get) { response in
                #expect(response.status == .ok)
                #expect(response.headers[.contentType] == "image/webp")
            }
            try await client.execute(uri: "/js/site.js", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    }
}

@Suite("Configuration")
struct ConfigurationTests {
    @Test func readsEnvironment() throws {
        let configuration = try ServerConfiguration.fromEnvironment([
            "PORT": "3000", "DATABASE_URL": " ", "STATIC_DIR": "/app/static", "LOG_LEVEL": "DEBUG",
        ])
        #expect(configuration.port == 3000)
        #expect(configuration.databaseURL == nil)
        #expect(configuration.staticDirectory == "/app/static")
        #expect(configuration.logLevel == .debug)
        #expect(try ServerConfiguration.fromEnvironment([:]).port == 8080)
    }

    @Test(arguments: ["0", "70000", "http"])
    func rejectsBadPorts(port: String) {
        #expect(throws: ConfigurationError.self) { try ServerConfiguration.fromEnvironment(["PORT": port]) }
    }

    @Test func parsesDatabaseURLs() throws {
        let url = try DatabaseURL("postgresql://penny:p%40ss@db.internal:6543/penny?sslmode=disable")
        #expect(url.host == "db.internal")
        #expect(url.port == 6543)
        #expect(url.username == "penny")
        #expect(url.password == "p@ss")
        #expect(url.database == "penny")
        #expect(url.sslMode == .disable)
        #expect(try DatabaseURL("postgres://u@localhost/x").sslMode == .prefer)
        #expect(throws: ConfigurationError.self) { try DatabaseURL("mysql://u@h/x") }
        #expect(throws: ConfigurationError.self) { try DatabaseURL("postgres://localhost/x") }
        #expect(throws: ConfigurationError.self) { try DatabaseURL("postgres://u@h/x?sslmode=bogus") }
    }

    @Test func commands() throws {
        #expect(try Command.parse([]) == .serve)
        #expect(try Command.parse(["seed"]) == .seed)
        #expect(throws: ConfigurationError.self) { try Command.parse(["deploy"]) }
    }

    @Test func currentPeriod() {
        // 2026-09-24T12:00:00Z was a Thursday.
        let period = BudgetPeriod.current(Date(timeIntervalSince1970: 1_790_251_200))
        #expect(period.today == MonthDay(month: 9, day: 24))
        #expect(period.weekday == "Thursday")
        #expect(period.days == 30)
    }

    @Test func seedMapsFeedAccountNames() {
        let household = Household.sample
        #expect(Seed.accountRowID(forTransactionAccount: "Joint checking", in: household) == "a1")
        #expect(Seed.accountRowID(forTransactionAccount: "Northstar Visa", in: household) == "a9")
        #expect(Seed.accountRowID(forTransactionAccount: "Maya’s debit", in: household) == "s3")
    }
}
