/// A calendar day without a year, as bills and transactions are shown ("Oct 1", "Sep 23").
public struct MonthDay: Hashable, Comparable, Sendable, Codable {
    public let month: Int
    public let day: Int

    public init(month: Int, day: Int) {
        precondition((1...12).contains(month), "Month out of range: \(month)")
        precondition((1...31).contains(day), "Day out of range: \(day)")
        self.month = month
        self.day = day
    }

    public static func < (lhs: MonthDay, rhs: MonthDay) -> Bool {
        (lhs.month, lhs.day) < (rhs.month, rhs.day)
    }

    /// `"Oct 1"`.
    public var label: String { "\(MonthDay.shortNames[month - 1]) \(day)" }

    /// Three-letter month name, `"Oct"`.
    public var shortMonth: String { MonthDay.shortNames[month - 1] }

    /// Full month name, `"October"`.
    public var longMonth: String { MonthDay.longNames[month - 1] }

    /// Parses `"Oct 1"` or `"October 1"`.
    public init?(label: String) {
        let parts = label.split(separator: " ")
        guard parts.count == 2, let day = Int(parts[1]), (1...31).contains(day) else { return nil }
        let name = parts[0].lowercased()
        guard let index = MonthDay.shortNames.firstIndex(where: { $0.lowercased() == name })
            ?? MonthDay.longNames.firstIndex(where: { $0.lowercased() == name })
        else { return nil }
        self.init(month: index + 1, day: day)
    }

    public static let shortNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    public static let longNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December",
    ]
}

/// The budgeting month the household is looking at, and how far into it "today" is.
public struct BudgetPeriod: Hashable, Sendable, Codable {
    /// Today's date within the month.
    public let today: MonthDay
    /// Day of the week for `today`, e.g. `"Wednesday"`.
    public let weekday: String
    /// Number of days in the month.
    public let days: Int

    public init(today: MonthDay, weekday: String, days: Int) {
        precondition(today.day <= days, "Today must fall inside the month")
        self.today = today
        self.weekday = weekday
        self.days = days
    }

    /// `"September"`.
    public var month: String { today.longMonth }
    /// `"Sep"`.
    public var shortMonth: String { today.shortMonth }
    /// Day of month for today, 1-based.
    public var day: Int { today.day }
    /// Days remaining after today.
    public var daysLeft: Int { days - today.day }
    /// `"Wednesday, September 24"`.
    public var todayLong: String { "\(weekday), \(month) \(today.day)" }
    /// `"Wednesday, Sep 24"`.
    public var todayShort: String { "\(weekday), \(shortMonth) \(today.day)" }

    /// `"Today"` for today, otherwise the short date (`"Sep 23"`).
    public func relativeLabel(for date: MonthDay) -> String {
        if date == today { return "Today" }
        return date.label
    }
}
