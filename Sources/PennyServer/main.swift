import Foundation
import PennyServerKit

do {
    let command = try Command.parse(Array(CommandLine.arguments.dropFirst()))
    let configuration = try ServerConfiguration.fromEnvironment()
    try await command.run(configuration: configuration)
} catch let error as ConfigurationError {
    FileHandle.standardError.write(Data((error.description + "\n").utf8))
    exit(64)
} catch {
    FileHandle.standardError.write(Data("penny-server: \(error)\n".utf8))
    exit(1)
}
