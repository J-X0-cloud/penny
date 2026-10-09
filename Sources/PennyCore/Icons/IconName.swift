/// Penny's 24×24 line icon set, drawn on a 1.8 px stroke. The raw value is the stable name used in
/// data (bills, categories) and by the web renderer.
public enum IconName: String, CaseIterable, Codable, Sendable {
    case cart, cup, fork, car, bag, ticket, heart, home
    case paw, bolt, wifi, shield, shieldck, phone, play, dumbbell
    case music, bank, trend, users, calendar, grid, list, pie
    case lock, eye, eyeoff, check, arrow, bell, split, sparkle
    case `repeat`, plus, search, sliders, chev, chevl, chevd, up
    case down, wallet, card, face, download, ban, target, tag
    case inbox, monitor, mail

    /// The shapes that make up this icon, in the 24×24 coordinate space.
    public var glyph: [IconShape] { IconGlyphs.shapes(for: self) }
}

/// One primitive of a line icon. Every shape is stroked, never filled.
public enum IconShape: Hashable, Sendable {
    /// SVG path data, with an optional dash pattern.
    case path(String, dash: [Double]? = nil)
    case circle(cx: Double, cy: Double, r: Double)
    case rect(x: Double, y: Double, width: Double, height: Double, cornerRadius: Double)
}

/// Stroke settings shared by every icon.
public enum IconStyle {
    public static let viewBox = 24.0
    public static let strokeWidth = 1.8
}
