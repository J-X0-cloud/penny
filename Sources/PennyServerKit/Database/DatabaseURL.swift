import Foundation
import NIOSSL
import PostgresNIO

/// A parsed `postgres://user:password@host:port/database?sslmode=...` connection string.
public struct DatabaseURL: Equatable, Sendable {
    public enum SSLMode: String, Sendable {
        /// Plain TCP (local development, private networks).
        case disable
        /// TLS when the server offers it.
        case prefer
        /// Fail unless the connection is encrypted.
        case require
    }

    public let host: String
    public let port: Int
    public let username: String
    public let password: String?
    public let database: String?
    public let sslMode: SSLMode

    public init(_ string: String) throws {
        guard let components = URLComponents(string: string),
              let scheme = components.scheme, ["postgres", "postgresql"].contains(scheme)
        else {
            throw ConfigurationError("DATABASE_URL must start with postgres:// or postgresql://")
        }
        guard let host = components.host, !host.isEmpty else {
            throw ConfigurationError("DATABASE_URL is missing a host")
        }
        guard let user = components.user, !user.isEmpty else {
            throw ConfigurationError("DATABASE_URL is missing a user name")
        }
        self.host = host
        self.port = components.port ?? 5432
        self.username = user.removingPercentEncoding ?? user
        self.password = components.password.map { $0.removingPercentEncoding ?? $0 }
        let path = components.path.drop { $0 == "/" }
        self.database = path.isEmpty ? nil : String(path)

        let mode = components.queryItems?.first { $0.name == "sslmode" }?.value ?? SSLMode.prefer.rawValue
        switch mode {
        case "disable", "allow": sslMode = .disable
        case "prefer": sslMode = .prefer
        case "require", "verify-ca", "verify-full": sslMode = .require
        default: throw ConfigurationError("Unsupported sslmode '\(mode)'; use disable, prefer or require")
        }
    }

    /// Client configuration for PostgresNIO's connection pool.
    public var clientConfiguration: PostgresClient.Configuration {
        let tls: PostgresClient.Configuration.TLS = switch sslMode {
        case .disable: .disable
        case .prefer: .prefer(.makeClientConfiguration())
        case .require: .require(.makeClientConfiguration())
        }
        return PostgresClient.Configuration(host: host, port: port, username: username, password: password, database: database, tls: tls)
    }
}
