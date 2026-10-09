import Foundation
import PennyCore
import Testing
@testable import PennyClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@Suite("API client")
struct PennyAPIClientTests {
    let base = URL(string: "https://penny.example.com")!

    @Test func buildsRequests() throws {
        let list = try Endpoint.transactions(category: .coffee, limit: 5).request(relativeTo: base)
        #expect(list.httpMethod == "GET")
        #expect(list.url?.absoluteString == "https://penny.example.com/api/transactions?category=coffee&limit=5")

        let patch = try Endpoint.recategorize(API.Recategorize(id: "t1", category: .home)).request(relativeTo: base)
        #expect(patch.httpMethod == "PATCH")
        #expect(patch.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let body = try JSONSerialization.jsonObject(with: try #require(patch.httpBody)) as? [String: String]
        #expect(body == ["id": "t1", "category": "home"])

        let settle = try Endpoint.settle(SettleUpRequest(from: .jordan, to: .maya, amount: 109)).request(relativeTo: base)
        #expect(settle.url?.path == "/api/household/settle")
        let settleBody = try JSONSerialization.jsonObject(with: try #require(settle.httpBody)) as? [String: Any]
        #expect(settleBody?["from"] as? String == "J")
        #expect(settleBody?["amount"] as? Double == 109)
        #expect(settleBody?["method"] as? String == "transfer")
    }

    @Test func respectsABasePath() throws {
        let request = try Endpoint.summary.request(relativeTo: URL(string: "https://example.com/penny/")!)
        #expect(request.url?.absoluteString == "https://example.com/penny/api/summary")
    }

    @Test func decodesSuccessfulResponses() async throws {
        let client = PennyAPIClient(baseURL: base) { request in
            let summary = API.Summary(household: .sample)
            return (try JSONEncoder().encode(summary), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let summary = try await client.summary()
        #expect(summary.netWorth.total == Household.sample.netWorth)
    }

    @Test func surfacesServerErrors() async {
        let client = PennyAPIClient(baseURL: base) { request in
            (Data(#"{"error":"Transaction not found"}"#.utf8), HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!)
        }
        do {
            _ = try await client.recategorize(transactionID: "x", to: .fun)
            Issue.record("expected an error")
        } catch let error as PennyAPIError {
            #expect(error == .server(status: 404, detail: .message("Transaction not found")))
            #expect(error.message == "Transaction not found")
        } catch {
            Issue.record("unexpected error \(error)")
        }
    }

    @Test func fieldErrorsBecomeAReadableMessage() {
        let error = PennyAPIError.server(status: 422, detail: .fields(ValidationError(field: "amount", "Number must be greater than 0")))
        #expect(error.message == "amount: Number must be greater than 0")
    }
}
