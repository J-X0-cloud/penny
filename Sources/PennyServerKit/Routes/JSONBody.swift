import Foundation
import Hummingbird
import PennyCore

/// Any JSON value. Request bodies are decoded into this first so validation can report a precise
/// message per field ("Required", "Expected number, received string") instead of a generic
/// decoding failure.
enum JSONValue: Decodable, Equatable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            self = .object(try container.decode([String: JSONValue].self))
        }
    }

    /// The type name used in validation messages.
    var typeName: String {
        switch self {
        case .null: "null"
        case .bool: "boolean"
        case .number: "number"
        case .string: "string"
        case .array: "array"
        case .object: "object"
        }
    }
}

/// Field-by-field reader over a JSON object body that accumulates validation errors.
struct JSONFields {
    private let object: [String: JSONValue]
    private(set) var errors = ValidationError()

    /// Parses `data` as a JSON object; anything else is reported as a body-level error.
    init(_ data: Data) throws(ValidationError) {
        guard let value = try? JSONDecoder().decode(JSONValue.self, from: data) else {
            throw ValidationError(field: "body", "Expected a JSON object")
        }
        guard case let .object(object) = value else {
            throw ValidationError(field: "body", "Expected object, received \(value.typeName)")
        }
        self.object = object
    }

    /// A required, non-empty string.
    mutating func string(_ key: String) -> String? {
        switch object[key] {
        case nil, .null?:
            errors.add(key, "Required")
        case let .string(value)?:
            if value.isEmpty {
                errors.add(key, "String must contain at least 1 character(s)")
            } else {
                return value
            }
        case let other?:
            errors.add(key, "Expected string, received \(other.typeName)")
        }
        return nil
    }

    /// A required string that must be one of `T`'s raw values. With `default`, a missing value is
    /// allowed and returns the default.
    mutating func enumeration<T: RawRepresentable & CaseIterable>(_ key: String, as type: T.Type, default fallback: T? = nil) -> T?
    where T.RawValue == String {
        let options = T.allCases.map { "'\($0.rawValue)'" }.joined(separator: " | ")
        switch object[key] {
        case nil, .null?:
            if let fallback { return fallback }
            errors.add(key, "Required")
        case let .string(value)?:
            if let match = T(rawValue: value) { return match }
            errors.add(key, "Invalid enum value. Expected \(options), received '\(value)'")
        case let other?:
            errors.add(key, "Expected \(options), received \(other.typeName)")
        }
        return nil
    }

    /// A required dollar amount: a positive number with at most two decimal places.
    mutating func positiveCents(_ key: String) -> Money? {
        switch object[key] {
        case nil, .null?:
            errors.add(key, "Required")
        case let .number(value)?:
            let cents = value * 100
            if !value.isFinite {
                errors.add(key, "Expected number, received nan")
            } else if value <= 0 {
                errors.add(key, "Number must be greater than 0")
            } else if abs(cents - cents.rounded()) > 1e-6 {
                errors.add(key, "Number must be a multiple of 0.01")
            } else {
                return Money(dollars: value)
            }
        case let other?:
            errors.add(key, "Expected number, received \(other.typeName)")
        }
        return nil
    }
}
