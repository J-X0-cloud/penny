/// An sRGB colour written the way the design tokens are: `"#5B3FD9"`. Kept platform-neutral so the
/// web renderer can emit CSS and the SwiftUI layer can build a `Color` from the same value.
public struct HexColor: Hashable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Parses `#RRGGBB` or `RRGGBB`. Returns `nil` for anything else.
    public init?(hex: String) {
        let digits = hex.hasPrefix("#") ? hex.dropFirst() : Substring(hex)
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        self.init(red: UInt8((value >> 16) & 0xFF), green: UInt8((value >> 8) & 0xFF), blue: UInt8(value & 0xFF))
    }

    /// Uppercase `#RRGGBB`, the form used in the stylesheet.
    public var css: String {
        "#" + [red, green, blue].map { component in
            let text = String(component, radix: 16, uppercase: true)
            return text.count == 1 ? "0" + text : text
        }.joined()
    }

    /// Components in 0...1 for graphics frameworks.
    public var unitComponents: (red: Double, green: Double, blue: Double) {
        (Double(red) / 255, Double(green) / 255, Double(blue) / 255)
    }
}

extension HexColor: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        guard let color = HexColor(hex: value) else {
            preconditionFailure("Invalid hex colour literal: \(value)")
        }
        self = color
    }
}

extension HexColor: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        guard let color = HexColor(hex: text) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected #RRGGBB, got \(text)")
        }
        self = color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(css)
    }
}

extension HexColor: CustomStringConvertible {
    public var description: String { css }
}

/// Brand palette shared by the site, the web dashboard and the iPhone app.
public enum Palette {
    public static let background: HexColor = "#F7F4EF"
    public static let appBackground: HexColor = "#FBFAF8"
    public static let paper: HexColor = "#FFFFFF"
    public static let ink: HexColor = "#1B1633"
    public static let ink2: HexColor = "#4A4560"
    public static let muted: HexColor = "#7C7791"
    public static let line: HexColor = "#E8E3DB"
    public static let line2: HexColor = "#EFEBF4"
    public static let violet: HexColor = "#5B3FD9"
    public static let violetDark: HexColor = "#3F2AA6"
    public static let violetLight: HexColor = "#EEE9FD"
    public static let lavender: HexColor = "#B9A8FF"
    public static let copper: HexColor = "#C8743C"
    public static let copperLight: HexColor = "#F7E3D2"
    public static let green: HexColor = "#1C9B74"
    public static let greenLight: HexColor = "#DDF3EA"
    public static let rose: HexColor = "#D4485B"
    public static let roseLight: HexColor = "#FBE3E6"
    public static let track: HexColor = "#ECE8F6"
    public static let tabInactive: HexColor = "#A19CB3"
    public static let heroTop: HexColor = "#6A4FE6"
    public static let heroBottom: HexColor = "#3A2399"
    public static let heroAccent: HexColor = "#FFD9B8"
    /// Gradient stops for each member's avatar.
    public static let mayaGradient: [HexColor] = ["#8C74F0", "#5B3FD9"]
    public static let jordanGradient: [HexColor] = ["#E39A5F", "#B25F2B"]
}
