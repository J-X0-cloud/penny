import Foundation
import Logging

/// Runtime settings, read from the environment so the same image runs locally and on Railway.
public struct ServerConfiguration: Sendable {
    /// Interface to bind. `0.0.0.0` inside containers.
    public var host: String
    /// Port to listen on; Railway injects `PORT`.
    public var port: Int
    /// Postgres connection string. When absent the API serves the bundled sample ledger.
    public var databaseURL: String?
    /// Folder holding `css/`, `js/`, `images/` and `icon.svg`.
    public var staticDirectory: String
    public var logLevel: Logger.Level

    public init(
        host: String = "0.0.0.0", port: Int = 8080, databaseURL: String? = nil,
        staticDirectory: String = "static", logLevel: Logger.Level = .info
    ) {
        self.host = host
        self.port = port
        self.databaseURL = databaseURL
        self.staticDirectory = staticDirectory
        self.logLevel = logLevel
    }

    /// Reads `HOST`, `PORT`, `DATABASE_URL`, `STATIC_DIR` and `LOG_LEVEL`. Empty values count as unset.
    public static func fromEnvironment(_ environment: [String: String] = ProcessInfo.processInfo.environment) throws -> ServerConfiguration {
        func value(_ key: String) -> String? {
            guard let raw = environment[key]?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return nil }
            return raw
        }
        var configuration = ServerConfiguration()
        if let host = value("HOST") { configuration.host = host }
        if let rawPort = value("PORT") {
            guard let port = Int(rawPort), (1...65_535).contains(port) else {
                throw ConfigurationError("PORT must be a number between 1 and 65535, got \(rawPort)")
            }
            configuration.port = port
        }
        configuration.databaseURL = value("DATABASE_URL")
        if let directory = value("STATIC_DIR") { configuration.staticDirectory = directory }
        if let rawLevel = value("LOG_LEVEL") {
            guard let level = Logger.Level(rawValue: rawLevel.lowercased()) else {
                throw ConfigurationError("LOG_LEVEL must be one of trace, debug, info, notice, warning, error, critical")
            }
            configuration.logLevel = level
        }
        return configuration
    }
}

public struct ConfigurationError: Error, CustomStringConvertible, Equatable {
    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
