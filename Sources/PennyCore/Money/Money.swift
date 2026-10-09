/// An amount of US dollars stored as integer cents, so sums and splits never drift the way binary
/// floating point does. Negative values are debts (loans, card balances).
public struct Money: Hashable, Comparable, Sendable {
    public var cents: Int

    public init(cents: Int) {
        self.cents = cents
    }

    /// Rounds a dollar amount to the nearest cent (half away from zero).
    public init(dollars: Double) {
        self.cents = Int((dollars * 100).rounded(.toNearestOrAwayFromZero))
    }

    public static let zero = Money(cents: 0)

    /// Dollars as a floating-point value, for ratios and chart geometry only.
    public var dollars: Double { Double(cents) / 100 }

    public var isNegative: Bool { cents < 0 }
    public var magnitude: Money { Money(cents: abs(cents)) }

    /// Rounds to whole dollars, half away from zero, matching how the screens show "$2,250".
    public var roundedToDollars: Money {
        let whole = (Double(cents) / 100).rounded(.toNearestOrAwayFromZero)
        return Money(cents: Int(whole) * 100)
    }

    public static func < (lhs: Money, rhs: Money) -> Bool { lhs.cents < rhs.cents }

    /// Ratio of two amounts; returns 0 when the denominator is zero.
    public func fraction(of whole: Money) -> Double {
        whole.cents == 0 ? 0 : Double(cents) / Double(whole.cents)
    }

    /// Multiplies by a ratio and rounds to the nearest cent.
    public func scaled(by factor: Double) -> Money {
        Money(cents: Int((Double(cents) * factor).rounded(.toNearestOrAwayFromZero)))
    }

    /// Divides into `parts` amounts that differ by at most one cent and sum back to `self`.
    /// The leftover cents go to the first parts, so `$10.00 / 3` is `[3.34, 3.33, 3.33]`.
    public func split(into parts: Int) -> [Money] {
        precondition(parts > 0, "Cannot split money into zero parts")
        let base = cents / parts
        let remainder = cents - base * parts
        let step = remainder >= 0 ? 1 : -1
        return (0..<parts).map { index in
            Money(cents: base + (index < abs(remainder) ? step : 0))
        }
    }
}

extension Money: AdditiveArithmetic {
    public static func + (lhs: Money, rhs: Money) -> Money { Money(cents: lhs.cents + rhs.cents) }
    public static func - (lhs: Money, rhs: Money) -> Money { Money(cents: lhs.cents - rhs.cents) }
    public static prefix func - (value: Money) -> Money { Money(cents: -value.cents) }
}

extension Money: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    /// Integer literals are whole dollars: `2150` is $2,150.00.
    public init(integerLiteral dollars: Int) {
        self.cents = dollars * 100
    }

    /// Float literals are dollars and cents: `548.2` is $548.20.
    public init(floatLiteral dollars: Double) {
        self.init(dollars: dollars)
    }
}

extension Money: Codable {
    /// Money travels over the API as a dollar number (`1708.42`), the shape the web and iPhone
    /// clients have always read. Decoding rounds to the nearest cent.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(dollars: try container.decode(Double.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dollars)
    }
}

extension Sequence where Element == Money {
    public func sum() -> Money { reduce(.zero, +) }
}

extension Sequence {
    public func sum(_ amount: (Element) -> Money) -> Money {
        reduce(.zero) { $0 + amount($1) }
    }
}

extension Money: CustomStringConvertible {
    public var description: String { MoneyFormat.money(self) }
}
