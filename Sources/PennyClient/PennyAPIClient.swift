import Foundation
import PennyCore
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Typed client for the Penny JSON API, used by the iPhone app to keep the review queue and the
/// settle-up balance in sync with the web.
public struct PennyAPIClient: Sendable {
    public let baseURL: URL
    private let transport: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    /// - Parameters:
    ///   - baseURL: Server origin, e.g. `https://penny.up.railway.app`.
    ///   - session: Session used for requests.
    public init(baseURL: URL, session: URLSession = .shared) {
        self.init(baseURL: baseURL) { request in try await session.data(for: request) }
    }

    /// Injects the transport; tests use this to answer requests without a network.
    public init(baseURL: URL, transport: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
        self.baseURL = baseURL
        self.transport = transport
    }

    public func summary() async throws -> API.Summary {
        try await send(Endpoint.summary)
    }

    public func transactions(category: CategoryKey? = nil, limit: Int? = nil) async throws -> [API.TransactionResource] {
        let list: API.TransactionList = try await send(.transactions(category: category, limit: limit))
        return list.transactions
    }

    public func recategorize(transactionID: String, to category: CategoryKey) async throws -> API.TransactionResource {
        let envelope: API.TransactionEnvelope = try await send(.recategorize(API.Recategorize(id: transactionID, category: category)))
        return envelope.transaction
    }

    public func settle(_ request: SettleUpRequest) async throws -> SettlementResult {
        try await send(.settle(request))
    }

    // MARK: - Plumbing

    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        let request = try endpoint.request(relativeTo: baseURL)
        let (data, response) = try await transport(request)
        return try Self.decode(Response.self, data: data, response: response)
    }

    static func decode<Response: Decodable>(_ type: Response.Type, data: Data, response: URLResponse) throws -> Response {
        guard let http = response as? HTTPURLResponse else { throw PennyAPIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let body = try? JSONDecoder().decode(API.ErrorBody.self, from: data)
            throw PennyAPIError.server(status: http.statusCode, detail: body?.error)
        }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw PennyAPIError.undecodable(String(describing: error))
        }
    }
}

public enum PennyAPIError: Error, Equatable, Sendable {
    case invalidResponse
    case server(status: Int, detail: API.ErrorBody.Detail?)
    case undecodable(String)

    /// A sentence suitable for an alert.
    public var message: String {
        switch self {
        case .invalidResponse:
            "Penny couldn't reach the server."
        case let .server(status, detail):
            switch detail {
            case let .message(text)?: text
            case let .fields(errors)?: errors.description
            case nil: "The server returned an error (\(status))."
            }
        case .undecodable:
            "Penny received a response it couldn't read."
        }
    }
}

/// The API's routes.
enum Endpoint {
    case summary
    case transactions(category: CategoryKey?, limit: Int?)
    case recategorize(API.Recategorize)
    case settle(SettleUpRequest)

    func request(relativeTo baseURL: URL) throws -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let basePath = components?.path.hasSuffix("/") == true ? String(components!.path.dropLast()) : (components?.path ?? "")
        let method: String
        var body: Data?
        switch self {
        case .summary:
            components?.path = basePath + "/api/summary"
            method = "GET"
        case let .transactions(category, limit):
            components?.path = basePath + "/api/transactions"
            var items: [URLQueryItem] = []
            if let category { items.append(URLQueryItem(name: "category", value: category.rawValue)) }
            if let limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
            components?.queryItems = items.isEmpty ? nil : items
            method = "GET"
        case let .recategorize(payload):
            components?.path = basePath + "/api/transactions"
            method = "PATCH"
            body = try JSONEncoder().encode(payload)
        case let .settle(payload):
            components?.path = basePath + "/api/household/settle"
            method = "POST"
            body = try JSONEncoder().encode(payload)
        }
        guard let url = components?.url else { throw PennyAPIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}
