import Foundation
import Hummingbird
import Logging
import PennyCore
import PostgresNIO

/// `penny-server [serve | migrate | seed]`.
public enum Command: String, CaseIterable, Sendable {
    /// Run the web server (default).
    case serve
    /// Create or update the database schema.
    case migrate
    /// Migrate, then load the sample household.
    case seed

    public static func parse(_ arguments: [String]) throws -> Command {
        guard let first = arguments.first else { return .serve }
        if first == "--help" || first == "-h" { throw ConfigurationError(usage) }
        guard let command = Command(rawValue: first) else {
            throw ConfigurationError("Unknown command '\(first)'.\n\(usage)")
        }
        return command
    }

    public static let usage = """
        Usage: penny-server [serve | migrate | seed]
          serve    Run the site and API on $PORT (default 8080)
          migrate  Create Penny's tables in $DATABASE_URL
          seed     Migrate, then load the sample household
        """

    public func run(configuration: ServerConfiguration) async throws {
        switch self {
        case .serve:
            let app = try PennyApplication.make(configuration: configuration)
            try await app.runService()
        case .migrate, .seed:
            guard let databaseURL = configuration.databaseURL else {
                throw ConfigurationError("\(rawValue) needs DATABASE_URL")
            }
            var logger = Logger(label: "penny")
            logger.logLevel = configuration.logLevel
            let client = PostgresClient(configuration: try DatabaseURL(databaseURL).clientConfiguration, backgroundLogger: logger)
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { await client.run() }
                try await Schema.migrate(client, logger: logger)
                if self == .seed {
                    let year = Calendar(identifier: .gregorian).component(.year, from: Date())
                    try await Seed.load(.sample, into: client, year: year, logger: logger)
                }
                group.cancelAll()
            }
        }
    }
}
