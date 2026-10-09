import Foundation
import Testing
@testable import PennyCore

@Suite("Ledger")
struct LedgerTests {
    @Test func listsEverythingByDefault() async throws {
        let ledger = InMemoryLedger()
        let rows = try await ledger.transactions(matching: TransactionQuery())
        #expect(rows.map(\.id) == ["t1", "t2", "t3", "t4", "t5", "t6", "t7"])
    }

    @Test func filtersByCategoryAndLimits() async throws {
        let ledger = InMemoryLedger()
        #expect(try await ledger.transactions(matching: TransactionQuery(category: .dining)).map(\.merchant) == ["Nori House"])
        #expect(try await ledger.transactions(matching: TransactionQuery(limit: 2)).count == 2)
    }

    @Test func recategorizeMarksReviewedAndPersists() async throws {
        let ledger = InMemoryLedger()
        let updated = try await ledger.recategorize(transactionID: "t6", to: .home)
        #expect(updated?.category == .home)
        #expect(updated?.reviewed == true)
        let homes = try await ledger.transactions(matching: TransactionQuery(category: .home))
        #expect(homes.map(\.id) == ["t6"])
    }

    @Test func recategorizeUnknownIDReturnsNil() async throws {
        #expect(try await InMemoryLedger().recategorize(transactionID: "nope", to: .fun) == nil)
    }

    @Test func queryParsingAcceptsValidParameters() throws {
        let query = try TransactionQuery(category: "coffee", limit: "10")
        #expect(query == TransactionQuery(category: .coffee, limit: 10))
        #expect(try TransactionQuery(category: "", limit: nil) == TransactionQuery())
    }

    @Test func queryParsingCollectsEveryError() {
        do {
            _ = try TransactionQuery(category: "rent", limit: "0")
            Issue.record("expected a validation error")
        } catch {
            #expect(error.fields["category"]?.first?.contains("received 'rent'") == true)
            #expect(error.fields["limit"] == ["Number must be greater than or equal to 1"])
        }
    }

    @Test(arguments: [("201", "Number must be less than or equal to 200"), ("2.5", "Expected integer, received float"), ("ten", "Expected number, received nan")])
    func limitErrors(raw: String, message: String) {
        #expect(throws: ValidationError(field: "limit", message)) {
            try TransactionQuery(category: nil, limit: raw)
        }
    }
}

@Suite("API models")
struct APIModelTests {
    @Test func summaryMatchesTheHousehold() throws {
        let summary = API.Summary(household: .sample)
        #expect(summary.spending.spent == 1708.42)
        #expect(summary.spending.underPace == 92)
        #expect(summary.bills.next30Days == 2572.4)
        #expect(summary.netWorth.groups.count == 4)
        #expect(summary.household.owedToMaya == 109)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let json = String(decoding: try encoder.encode(summary.period), as: UTF8.self)
        #expect(json == #"{"day":24,"days":30,"month":"September"}"#)
        let round = try JSONDecoder().decode(API.Summary.self, from: try encoder.encode(summary))
        #expect(round == summary)
    }

    @Test func transactionResourceUsesRelativeDates() throws {
        let household = Household.sample
        let today = API.TransactionResource(household.transactions[0], period: household.period)
        let earlier = API.TransactionResource(household.transactions[3], period: household.period)
        #expect(today.date == "Today")
        #expect(earlier.date == "Sep 23")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let json = String(decoding: try encoder.encode(today), as: UTF8.self)
        #expect(json == #"{"account":"Joint checking","amount":57.81,"category":"groceries","date":"Today","id":"t1","merchant":"Harvest Co-op","paidBy":"M"}"#)
    }

    @Test func errorBodies() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        #expect(String(decoding: try encoder.encode(API.ErrorBody("Transaction not found")), as: UTF8.self) == #"{"error":"Transaction not found"}"#)
        let fields = API.ErrorBody(ValidationError(field: "id", "Required"))
        #expect(String(decoding: try encoder.encode(fields), as: UTF8.self) == #"{"error":{"id":["Required"]}}"#)
        #expect(try JSONDecoder().decode(API.ErrorBody.self, from: try encoder.encode(fields)) == fields)
    }

    @Test func colorsRoundTrip() throws {
        #expect(HexColor(hex: "#1c9b74")?.css == "#1C9B74")
        #expect(HexColor(hex: "1C9B7") == nil)
        #expect(HexColor(hex: "#GGGGGG") == nil)
        let decoded = try JSONDecoder().decode(HexColor.self, from: Data(##""#5B3FD9""##.utf8))
        #expect(decoded == Palette.violet)
    }
}
