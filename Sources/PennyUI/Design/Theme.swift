#if os(iOS)
import PennyCore
import SwiftUI

extension Color {
    /// A colour from the shared brand palette.
    init(_ hex: HexColor, opacity: Double = 1) {
        let components = hex.unitComponents
        self.init(.sRGB, red: components.red, green: components.green, blue: components.blue, opacity: opacity)
    }
}

/// Penny's design tokens, matching the web stylesheet so the phone and the site read as one product.
enum Theme {
    static var background: Color { Color(Palette.appBackground) }
    static var paper: Color { Color(Palette.paper) }
    static var ink: Color { Color(Palette.ink) }
    static var ink2: Color { Color(Palette.ink2) }
    static var muted: Color { Color(Palette.muted) }
    static var line: Color { Color(Palette.line) }
    static var line2: Color { Color(Palette.line2) }
    static var violet: Color { Color(Palette.violet) }
    static var violetDark: Color { Color(Palette.violetDark) }
    static var violetLight: Color { Color(Palette.violetLight) }
    static var copper: Color { Color(Palette.copper) }
    static var copperLight: Color { Color(Palette.copperLight) }
    static var green: Color { Color(Palette.green) }
    static var rose: Color { Color(Palette.rose) }
    static var track: Color { Color(Palette.track) }
    static var tabInactive: Color { Color(Palette.tabInactive) }
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [Color(Palette.heroTop), Color(Palette.heroBottom)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var heroAccent: Color { Color(Palette.heroAccent) }

    static func gradient(for member: MemberID) -> LinearGradient {
        let stops = member == .maya ? Palette.mayaGradient : Palette.jordanGradient
        return LinearGradient(colors: stops.map { Color($0) }, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    enum Radius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
    }
}

/// Type ramp. The serif carries the big figures and titles, as Fraunces does on the web.
enum Typography {
    static func serif(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

extension Money {
    /// `"$1,708.42"`.
    var formatted: String { MoneyFormat.money(self) }
    /// `"$2,250"`.
    var whole: String { MoneyFormat.money(self, decimals: 0) }
}
#endif
