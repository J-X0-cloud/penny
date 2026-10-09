import Foundation
import Testing
@testable import PennyCore

@Suite("Money")
struct MoneyTests {
    @Test func literalsAreDollars() {
        let whole: Money = 2150
        let cents: Money = 548.2
        #expect(whole.cents == 215_000)
        #expect(cents.cents == 54_820)
    }

    @Test func roundingFromDoubleIsHalfAwayFromZero() {
        #expect(Money(dollars: 0.125).cents == 13)
        #expect(Money(dollars: -0.125).cents == -13)
        // 0.1 + 0.2 is not 0.3 in binary floating point; Money absorbs it.
        #expect(Money(dollars: 0.1 + 0.2) == Money(dollars: 0.3))
    }

    @Test func sumsAreExact() {
        let amounts: [Money] = [548.2, 312.75, 214.1, 186.4, 142.37, 96.3, 88, 64, 56.3]
        #expect(amounts.sum() == 1708.42)
    }

    @Test func roundedToDollars() {
        #expect(Money(cents: 9158).roundedToDollars == 92)
        #expect(Money(cents: 9150).roundedToDollars == 92)
        #expect(Money(cents: 9149).roundedToDollars == 91)
        #expect(Money(cents: -9150).roundedToDollars == -92)
    }

    @Test(arguments: [(1000, 3), (1, 2), (-1000, 3), (248_620, 2), (7, 7)])
    func splitAddsBackUpAndDiffersByAtMostOneCent(cents: Int, parts: Int) {
        let pieces = Money(cents: cents).split(into: parts)
        #expect(pieces.count == parts)
        #expect(pieces.sum() == Money(cents: cents))
        let values = pieces.map(\.cents)
        #expect(values.max()! - values.min()! <= 1)
    }

    @Test func splitGivesLeftoverCentsToTheFirstParts() {
        #expect(Money(cents: 1000).split(into: 3).map(\.cents) == [334, 333, 333])
    }

    @Test func fractionOfZeroIsZero() {
        #expect(Money(cents: 500).fraction(of: .zero) == 0)
        #expect(Money(cents: 500).fraction(of: Money(cents: 1000)) == 0.5)
    }

    @Test func encodesAsDollarNumber() throws {
        let data = try JSONEncoder().encode(["spent": Money(cents: 170_842)])
        #expect(String(decoding: data, as: UTF8.self) == #"{"spent":1708.42}"#)
        let decoded = try JSONDecoder().decode(Money.self, from: Data("86.42".utf8))
        #expect(decoded.cents == 8642)
    }
}

@Suite("Money formatting")
struct MoneyFormatTests {
    @Test(arguments: [
        (Money(cents: 170_842), 2, "$1,708.42"),
        (Money(cents: -1_124_018), 2, "-$11,240.18"),
        (Money(cents: 225_000), 0, "$2,250"),
        (Money(cents: 54_158), 0, "$542"),
        (Money(cents: 140_826_470), 0, "$1,408,265"),
        (Money(cents: 5), 2, "$0.05"),
        (Money.zero, 0, "$0"),
        (Money(cents: -184_237), 0, "-$1,842"),
    ])
    func money(value: Money, decimals: Int, expected: String) {
        #expect(MoneyFormat.money(value, decimals: decimals) == expected)
    }

    @Test func thousands() {
        #expect(MoneyFormat.thousands(38400) == "$38.4k")
        #expect(MoneyFormat.thousands(80000) == "$80.0k")
    }

    @Test func splitForDisplayFigures() {
        let parts = MoneyFormat.split(1708.42)
        #expect(parts.dollars == "$1,708")
        #expect(parts.cents == "42")
        #expect(MoneyFormat.split(2150).cents == "00")
    }

    @Test func percentAndFixed() {
        #expect(MoneyFormat.percent(3.857, decimals: 1) == "3.9%")
        #expect(MoneyFormat.percent(39.29) == "39%")
        #expect(MoneyFormat.fixed(-2.899, decimals: 1) == "-2.9")
        #expect(MoneyFormat.fixed(-0.04, decimals: 1) == "0.0")
        #expect(MoneyFormat.number(1234.5, decimals: 2) == "1,234.50")
    }

    @Test func grouping() {
        #expect(MoneyFormat.grouped(0) == "0")
        #expect(MoneyFormat.grouped(999) == "999")
        #expect(MoneyFormat.grouped(1000) == "1,000")
        #expect(MoneyFormat.grouped(-1_234_567) == "-1,234,567")
    }
}
