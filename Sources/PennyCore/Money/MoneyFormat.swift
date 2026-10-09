/// Locale-independent en-US formatting for every figure Penny shows. The same strings render on the
/// iPhone, the site and in API error messages, so formatting is done by hand rather than through a
/// platform `NumberFormatter` whose output varies with the device locale.
public enum MoneyFormat {
    /// `1708.42` -> `"$1,708.42"`; `-11240.18` -> `"-$11,240.18"`; `money(2250, decimals: 0)` -> `"$2,250"`.
    public static func money(_ value: Money, decimals: Int = 2) -> String {
        precondition(decimals == 0 || decimals == 2, "Money renders with 0 or 2 decimals")
        let sign = value.isNegative ? "-" : ""
        if decimals == 0 {
            return sign + "$" + grouped(value.magnitude.roundedToDollars.cents / 100)
        }
        let cents = abs(value.cents)
        return sign + "$" + grouped(cents / 100) + "." + padded(cents % 100, width: 2)
    }

    /// `38400` -> `"$38.4k"`.
    public static func thousands(_ value: Money) -> String {
        let sign = value.isNegative ? "-" : ""
        return sign + "$" + number(abs(value.dollars) / 1000, decimals: 1) + "k"
    }

    /// Splits an amount into whole dollars and cents for the large display figures:
    /// `1708.42` -> `("$1,708", "42")`.
    public static func split(_ value: Money) -> (dollars: String, cents: String) {
        let cents = abs(value.cents)
        let sign = value.isNegative ? "-" : ""
        return (sign + "$" + grouped(cents / 100), padded(cents % 100, width: 2))
    }

    /// `3.857` -> `"3.9%"` with one decimal.
    public static func percent(_ value: Double, decimals: Int = 0) -> String {
        fixed(value, decimals: decimals) + "%"
    }

    /// A grouped decimal number: `number(38.4, decimals: 1)` -> `"38.4"`, `number(1234.5, decimals: 2)` -> `"1,234.50"`.
    public static func number(_ value: Double, decimals: Int) -> String {
        let (sign, whole, fraction) = digits(value, decimals: decimals)
        let body = grouped(whole)
        return sign + (decimals > 0 ? body + "." + fraction : body)
    }

    /// Like JavaScript's `toFixed`: no grouping, rounds half away from zero.
    public static func fixed(_ value: Double, decimals: Int) -> String {
        let (sign, whole, fraction) = digits(value, decimals: decimals)
        return sign + String(whole) + (decimals > 0 ? "." + fraction : "")
    }

    // MARK: - Helpers

    private static func digits(_ value: Double, decimals: Int) -> (sign: String, whole: Int, fraction: String) {
        precondition(decimals >= 0 && decimals <= 6, "Unsupported precision")
        var scale = 1
        for _ in 0..<decimals { scale *= 10 }
        let scaled = Int((abs(value) * Double(scale)).rounded(.toNearestOrAwayFromZero))
        let sign = value < 0 && scaled != 0 ? "-" : ""
        return (sign, scaled / scale, decimals > 0 ? padded(scaled % scale, width: decimals) : "")
    }

    /// `1234567` -> `"1,234,567"`.
    static func grouped(_ value: Int) -> String {
        let digits = String(abs(value))
        var result = ""
        for (offset, character) in digits.enumerated() {
            if offset > 0 && (digits.count - offset) % 3 == 0 {
                result.append(",")
            }
            result.append(character)
        }
        return (value < 0 ? "-" : "") + result
    }

    private static func padded(_ value: Int, width: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(0, width - text.count)) + text
    }
}
