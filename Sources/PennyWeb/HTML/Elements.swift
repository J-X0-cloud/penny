import PennyCore

/// One attribute on an element. A `nil` value renders as a bare boolean attribute (`open`), and
/// attributes built from optional input are dropped entirely when there is nothing to render.
public struct Attribute: Hashable, Sendable {
    public let name: String
    public let value: String?
    /// `false` when the attribute should not render at all (e.g. an empty class list).
    let present: Bool

    public init(_ name: String, _ value: String?) {
        self.name = name
        self.value = value
        self.present = true
    }

    private init(omitted name: String) {
        self.name = name
        self.value = nil
        self.present = false
    }

    static func omitted(_ name: String) -> Attribute { Attribute(omitted: name) }

    var rendered: String {
        guard let value else { return " " + name }
        return " \(name)=\"\(Escape.attribute(value))\""
    }
}

extension Attribute {
    /// Space-separated class list; `nil` and empty names are skipped, like `clsx`.
    public static func `class`(_ names: String?...) -> Attribute {
        let list = names.compactMap { $0 }.filter { !$0.isEmpty }
        return list.isEmpty ? .omitted("class") : Attribute("class", list.joined(separator: " "))
    }

    public static func id(_ value: String) -> Attribute { Attribute("id", value) }
    public static func href(_ value: String) -> Attribute { Attribute("href", value) }
    public static func src(_ value: String) -> Attribute { Attribute("src", value) }
    public static func alt(_ value: String) -> Attribute { Attribute("alt", value) }
    public static func role(_ value: String) -> Attribute { Attribute("role", value) }
    public static func type(_ value: String) -> Attribute { Attribute("type", value) }
    public static func title(_ value: String) -> Attribute { Attribute("title", value) }
    public static func width(_ value: Double) -> Attribute { Attribute("width", SVGNumber.format(value)) }
    public static func height(_ value: Double) -> Attribute { Attribute("height", SVGNumber.format(value)) }

    /// `aria-*` attribute.
    public static func aria(_ name: String, _ value: String) -> Attribute { Attribute("aria-\(name)", value) }
    public static func ariaHidden() -> Attribute { Attribute("aria-hidden", "true") }
    /// `data-*` attribute, read by the site script.
    public static func data(_ name: String, _ value: String) -> Attribute { Attribute("data-\(name)", value) }

    /// Boolean attribute such as `open` or `hidden`; omitted when `isOn` is false.
    public static func flag(_ name: String, _ isOn: Bool = true) -> Attribute {
        isOn ? Attribute(name, nil) : .omitted(name)
    }

    /// Inline style from ordered declarations; `nil` values are skipped.
    public static func style(_ declarations: KeyValuePairs<String, String?>) -> Attribute {
        let text = declarations.compactMap { property, value in value.map { "\(property):\($0)" } }
            .joined(separator: ";")
        return text.isEmpty ? .omitted("style") : Attribute("style", text)
    }
}

// MARK: - Element construction

func element(_ name: String, _ attributes: [Attribute], @HTMLBuilder content: () -> HTML) -> HTML {
    let attrs = attributes.filter(\.present).map(\.rendered).joined()
    return .raw("<\(name)\(attrs)>") + content() + .raw("</\(name)>")
}

/// Elements with no closing tag (`<img>`, `<meta>`, `<link>`).
func voidElement(_ name: String, _ attributes: [Attribute]) -> HTML {
    let attrs = attributes.filter(\.present).map(\.rendered).joined()
    return .raw("<\(name)\(attrs)>")
}

// MARK: - HTML elements

func div(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("div", attributes, content: content)
}
func span(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("span", attributes, content: content)
}
func p(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("p", attributes, content: content)
}
func a(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("a", attributes, content: content)
}
func b(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("b", attributes, content: content)
}
func small(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("small", attributes, content: content)
}
func em(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("em", attributes, content: content)
}
/// `<i>`, used throughout the stylesheet as a bare decorative box (bars, dots, swatches).
func italic(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("i", attributes, content: content)
}
func h1(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("h1", attributes, content: content) }
func h2(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("h2", attributes, content: content) }
func h3(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("h3", attributes, content: content) }
func h4(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("h4", attributes, content: content) }
func h5(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("h5", attributes, content: content) }
func section(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("section", attributes, content: content)
}
func article(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("article", attributes, content: content)
}
func nav(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("nav", attributes, content: content) }
func header(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("header", attributes, content: content)
}
func footer(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("footer", attributes, content: content)
}
func aside(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("aside", attributes, content: content) }
func ul(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("ul", attributes, content: content) }
func ol(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("ol", attributes, content: content) }
func li(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("li", attributes, content: content) }
func table(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("table", attributes, content: content) }
func thead(@HTMLBuilder content: () -> HTML) -> HTML { element("thead", [], content: content) }
func tbody(@HTMLBuilder content: () -> HTML) -> HTML { element("tbody", [], content: content) }
func tr(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("tr", attributes, content: content) }
func th(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("th", attributes, content: content)
}
func td(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("td", attributes, content: content) }
func figure(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("figure", attributes, content: content)
}
func blockquote(@HTMLBuilder content: () -> HTML) -> HTML { element("blockquote", [], content: content) }
func figcaption(@HTMLBuilder content: () -> HTML) -> HTML { element("figcaption", [], content: content) }
func details(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("details", attributes, content: content)
}
func summary(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML {
    element("summary", attributes, content: content)
}
func button(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML = { .empty }) -> HTML {
    element("button", [.type("button")] + attributes, content: content)
}
func img(src: String, alt: String = "", width: Double, height: Double, _ attributes: Attribute...) -> HTML {
    voidElement(
        "img",
        attributes + [.src(src), .alt(alt), .width(width), .height(height), Attribute("loading", "lazy"), Attribute("decoding", "async")]
    )
}

// MARK: - SVG elements

func svg(_ attributes: Attribute..., @HTMLBuilder content: () -> HTML) -> HTML { element("svg", attributes, content: content) }
func svgPath(_ attributes: Attribute...) -> HTML { element("path", attributes) { HTML.empty } }
func svgCircle(_ attributes: Attribute...) -> HTML { element("circle", attributes) { HTML.empty } }
func svgRect(_ attributes: Attribute...) -> HTML { element("rect", attributes) { HTML.empty } }
func svgLine(_ attributes: Attribute...) -> HTML { element("line", attributes) { HTML.empty } }
func svgDefs(@HTMLBuilder content: () -> HTML) -> HTML { element("defs", [], content: content) }

/// A two-stop vertical or diagonal gradient.
func linearGradient(id: String, x2: Double, y2: Double, stops: [(offset: Double, color: String, opacity: Double?)]) -> HTML {
    element("linearGradient", [.id(id), Attribute("x1", "0"), Attribute("y1", "0"), Attribute("x2", SVGNumber.format(x2)), Attribute("y2", SVGNumber.format(y2))]) {
        for stop in stops {
            element("stop", [
                Attribute("offset", SVGNumber.format(stop.offset)),
                Attribute("stop-color", stop.color),
                stop.opacity.map { Attribute("stop-opacity", SVGNumber.format($0)) } ?? .omitted("stop-opacity"),
            ]) { HTML.empty }
        }
    }
}

/// Shorthand for a numeric SVG attribute.
func num(_ name: String, _ value: Double) -> Attribute {
    Attribute(name, SVGNumber.format(value))
}
