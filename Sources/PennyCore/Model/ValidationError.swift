/// Field-level validation failures, keyed by input name. Serialises as `{"field": ["message", ...]}`,
/// the shape the API returns under `"error"`.
public struct ValidationError: Error, Hashable, Sendable, Codable {
    public private(set) var fields: [String: [String]]

    public init(fields: [String: [String]] = [:]) {
        self.fields = fields
    }

    public init(field: String, _ message: String) {
        self.fields = [field: [message]]
    }

    public var isEmpty: Bool { fields.isEmpty }

    public mutating func add(_ field: String, _ message: String) {
        fields[field, default: []].append(message)
    }

    public init(from decoder: Decoder) throws {
        fields = try decoder.singleValueContainer().decode([String: [String]].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fields)
    }
}

extension ValidationError: CustomStringConvertible {
    public var description: String {
        fields.keys.sorted().map { key in "\(key): \(fields[key, default: []].joined(separator: ", "))" }
            .joined(separator: "; ")
    }
}
