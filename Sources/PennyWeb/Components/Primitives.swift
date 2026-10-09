import PennyCore

/// Renders the product site for one household. Components are methods in extensions grouped by
/// area (primitives, charts, phone, cards, dashboard, sections, pages), mirroring how the pages are
/// composed.
public struct SiteRenderer: Sendable {
    public let household: Household

    public init(household: Household = .sample) {
        self.household = household
    }

    func money(_ value: Money, decimals: Int = 2) -> String {
        MoneyFormat.money(value, decimals: decimals)
    }

    func imageURL(_ name: String) -> String {
        "/images/\(name).webp"
    }

    func memberName(_ id: MemberID) -> String {
        household.member(id).name
    }
}

// MARK: - Icons and brand

extension SiteRenderer {
    /// One of the 24×24 line icons as inline SVG.
    func icon(_ name: IconName, class className: String = "ic") -> HTML {
        svg(
            .class(className), Attribute("viewBox", "0 0 24 24"), Attribute("fill", "none"),
            Attribute("stroke", "currentColor"), Attribute("stroke-width", "1.8"),
            Attribute("stroke-linecap", "round"), Attribute("stroke-linejoin", "round"), .ariaHidden()
        ) {
            for shape in name.glyph {
                switch shape {
                case let .path(data, dash):
                    svgPath(Attribute("d", data), dash.map { Attribute("stroke-dasharray", $0.map(SVGNumber.format).joined(separator: " ")) } ?? .class())
                case let .circle(cx, cy, r):
                    svgCircle(num("cx", cx), num("cy", cy), num("r", r))
                case let .rect(x, y, width, height, cornerRadius):
                    svgRect(num("x", x), num("y", y), num("width", width), num("height", height), num("rx", cornerRadius))
                }
            }
        }
    }

    func logoMark() -> HTML {
        let gradient = RenderScope.nextID("logo")
        return svg(.class("logo-mark"), Attribute("viewBox", "0 0 36 36"), .ariaHidden()) {
            svgDefs {
                linearGradient(id: gradient, x2: 1, y2: 1, stops: [(0, "#E39A5F", nil), (1, "#B25F2B", nil)])
            }
            svgCircle(num("cx", 18), num("cy", 18), num("r", 17), Attribute("fill", "url(#\(gradient))"))
            svgCircle(
                num("cx", 18), num("cy", 18), num("r", 13.2), Attribute("fill", "none"), Attribute("stroke", "#FBE3CC"),
                Attribute("stroke-opacity", ".55"), Attribute("stroke-width", "1")
            )
            svgRect(num("x", 12.2), num("y", 11), num("width", 3.8), num("height", 16), num("rx", 1.9), Attribute("fill", "#FFF8F1"))
            svgCircle(
                num("cx", 20), num("cy", 16.4), num("r", 4.4), Attribute("fill", "none"), Attribute("stroke", "#FFF8F1"),
                Attribute("stroke-width", "3.6")
            )
        }
    }

    enum WordmarkVariant: String {
        case light, sm
    }

    func wordmark(_ variant: WordmarkVariant? = nil) -> HTML {
        a(.class("brand", variant?.rawValue), .href("/"), .aria("label", "Penny home")) {
            logoMark()
            span { "penny" }
        }
    }
}

// MARK: - Small UI pieces

extension SiteRenderer {
    func avatar(_ who: MemberID, small isSmall: Bool = false) -> HTML {
        span(.class("av", isSmall ? "sm" : nil, "av-\(who.rawValue.lowercased())")) { who.initial }
    }

    func coupleAvatars(small isSmall: Bool = false) -> HTML {
        span(.class("avs")) {
            avatar(.maya, small: isSmall)
            avatar(.jordan, small: isSmall)
        }
    }

    enum ButtonVariant: String {
        case primary, line, copper
        case lineWhite = "line-w"
    }

    func linkButton(
        href: String, variant: ButtonVariant = .primary, large: Bool = false, block: Bool = false, arrow: Bool = false,
        _ label: String
    ) -> HTML {
        a(.class("btn", "btn-\(variant.rawValue)", large ? "btn-lg" : nil, block ? "btn-block" : nil), .href(href)) {
            label
            if arrow { icon(.arrow) }
        }
    }

    func categoryChip(_ key: CategoryKey, small isSmall: Bool = false) -> HTML {
        let category = household.category(key)
        return span(.class("cic", isSmall ? "sm" : nil), .style(["color": category.foreground.css, "background": category.tint.css])) {
            icon(category.icon)
        }
    }

    /// Brand-violet chip for bills, accounts and other non-category rows.
    func iconChip(_ name: IconName, small isSmall: Bool = false) -> HTML {
        span(.class("cic", isSmall ? "sm" : nil), .style(["color": Palette.violet.css, "background": Palette.violetLight.css])) {
            icon(name)
        }
    }

    func progressBar(fraction: Double, color: String? = nil) -> HTML {
        div(.class("bar")) {
            italic(.style(["width": percentWidth(fraction), "background": color]))
        }
    }

    func percentWidth(_ fraction: Double) -> String {
        "\(Int((min(max(fraction, 0), 1) * 100).rounded(.toNearestOrAwayFromZero)))%"
    }

    func eyebrow(_ text: String, dot: Bool = false) -> HTML {
        p(.class("eyebrow")) {
            if dot { span(.class("dot")) }
            text
        }
    }

    enum SectionTone: String {
        case light, left
    }

    /// Section heading with an optional eyebrow and supporting copy. `title` is markup so headings
    /// can carry the italic accent (`<em>`).
    func sectionHead(eyebrow text: String? = nil, tone: SectionTone? = nil, title: HTML, body: HTML? = nil) -> HTML {
        div(.class("sec-h", tone?.rawValue)) {
            if let text { eyebrow(text) }
            h2 { title }
            if let body { body }
        }
    }

    func sectionHead(eyebrow text: String? = nil, tone: SectionTone? = nil, title: HTML, body: String) -> HTML {
        sectionHead(eyebrow: text, tone: tone, title: title, body: p { body })
    }

    func iconList(_ items: [IconLabel]) -> HTML {
        ul(.class("ticks")) {
            for item in items {
                li {
                    icon(item.icon)
                    item.label
                }
            }
        }
    }

    func faqList(_ items: [FaqItem]) -> HTML {
        div {
            for (index, item) in items.enumerated() {
                details(.class("faq"), .flag("open", index == 0)) {
                    summary {
                        item.question
                        span()
                    }
                    p { item.answer }
                }
            }
        }
    }

    /// `Plain text <em>accent</em> more text`, the headline pattern used across the site.
    func headline(_ lead: String, accent: String, trailing: String = "") -> HTML {
        HTML.text(lead) + em { accent } + HTML.text(trailing)
    }
}
