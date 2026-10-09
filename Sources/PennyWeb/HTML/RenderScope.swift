import Foundation

/// Per-render state. SVG gradients need document-unique ids (a gradient inside a hidden preview
/// screen cannot be referenced by a visible one), so each page render gets its own counter and the
/// output stays deterministic: the same page always renders byte-for-byte the same.
enum RenderScope {
    @TaskLocal static var ids = UniqueIDs()

    /// Runs `body` with a fresh id counter.
    static func render<T>(_ body: () throws -> T) rethrows -> T {
        try $ids.withValue(UniqueIDs(), operation: body)
    }

    /// Next id with the given prefix, e.g. `"spend-3"`.
    static func nextID(_ prefix: String) -> String {
        "\(prefix)-\(ids.next())"
    }
}

final class UniqueIDs: @unchecked Sendable {
    private let lock = NSLock()
    private var counter = 0

    func next() -> Int {
        lock.lock()
        defer { lock.unlock() }
        counter += 1
        return counter
    }
}
