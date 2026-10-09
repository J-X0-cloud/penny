/// A fragment of already-escaped markup. Text only becomes `HTML` through ``HTML/text(_:)`` (or a
/// string inside an ``HTMLBuilder`` block), which escapes it, so interpolated content cannot inject
/// markup.
public struct HTML: Hashable, Sendable {
    public let rendered: String

    private init(rendered: String) {
        self.rendered = rendered
    }

    public static let empty = HTML(rendered: "")

    /// Escaped text content.
    public static func text(_ text: String) -> HTML {
        HTML(rendered: Escape.text(text))
    }

    /// Markup that is known to be safe, such as a static entity. Never pass user input.
    public static func raw(_ markup: String) -> HTML {
        HTML(rendered: markup)
    }

    public static func + (lhs: HTML, rhs: HTML) -> HTML {
        HTML(rendered: lhs.rendered + rhs.rendered)
    }

    public static func joined(_ parts: [HTML]) -> HTML {
        HTML(rendered: parts.map(\.rendered).joined())
    }
}

/// Builds HTML the way JSX does: statements are children, `if`/`switch` pick branches and `for` loops
/// repeat. Plain strings are escaped.
@resultBuilder
public enum HTMLBuilder {
    public static func buildExpression(_ html: HTML) -> HTML { html }
    public static func buildExpression(_ text: String) -> HTML { .text(text) }
    public static func buildExpression(_ parts: [HTML]) -> HTML { .joined(parts) }
    public static func buildBlock(_ parts: HTML...) -> HTML { .joined(parts) }
    public static func buildOptional(_ html: HTML?) -> HTML { html ?? .empty }
    public static func buildEither(first html: HTML) -> HTML { html }
    public static func buildEither(second html: HTML) -> HTML { html }
    public static func buildArray(_ parts: [HTML]) -> HTML { .joined(parts) }
    public static func buildLimitedAvailability(_ html: HTML) -> HTML { html }
}

enum Escape {
    static func text(_ value: String) -> String {
        var result = ""
        result.reserveCapacity(value.utf8.count)
        for character in value {
            switch character {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            default: result.append(character)
            }
        }
        return result
    }

    static func attribute(_ value: String) -> String {
        var result = ""
        result.reserveCapacity(value.utf8.count)
        for character in value {
            switch character {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"": result += "&quot;"
            case "'": result += "&#39;"
            default: result.append(character)
            }
        }
        return result
    }
}
