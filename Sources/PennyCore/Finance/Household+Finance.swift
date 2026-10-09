/// Derived numbers. Computed in one place from the household so every surface agrees.
extension Household {
    // MARK: Spending and budgets

    public var totalSpent: Money { categories.sum(\.spent) }
    public var totalBudget: Money { categories.sum(\.budget) }
    public var leftToBudget: Money { totalBudget - totalSpent }

    /// Where spending "should" be today if the budget were spent evenly across the month.
    public var budgetPace: Money {
        totalBudget.scaled(by: Double(period.day) / Double(period.days))
    }

    /// How far spending is below the even-pace line, in whole dollars (negative when ahead of pace).
    public var underPace: Money { (budgetPace - totalSpent).roundedToDollars }

    /// Cumulative spend at this point last month.
    public var lastMonthAtToday: Money {
        let index = period.day - 1
        return spendLastMonth.indices.contains(index) ? spendLastMonth[index] : .zero
    }

    /// Spend so far versus the same day last month, as a percentage (negative is less).
    public var versusLastMonthPercent: Double {
        guard lastMonthAtToday > .zero else { return 0 }
        return (totalSpent - lastMonthAtToday).fraction(of: lastMonthAtToday) * 100
    }

    public func budgetStatus(for category: Category) -> BudgetStatus {
        BudgetStatus(category: category)
    }

    public var budgetStatuses: [BudgetStatus] { categories.map(BudgetStatus.init) }

    // MARK: Bills

    /// Total of every recurring bill due in the next 30 days.
    public var billsTotal: Money { bills.sum(\.amount) }

    /// The first bill whose price went up, for the price-change alert.
    public var priceIncrease: Bill? { bills.first(where: \.increased) }

    public func bills(dueOn date: MonthDay) -> [Bill] {
        bills.filter { $0.due == date }
    }

    /// Seven days starting at `start`, flagged where a bill is due. Weekdays are worked out from
    /// the period's today, so the strip stays right when the sample month changes.
    public func billWeek(startingAt start: MonthDay) -> [CalendarDay] {
        let dueDates = Set(bills.map(\.due))
        let offset = DayArithmetic.days(from: period.today, to: start)
        let todayIndex = DayArithmetic.weekdayIndex(period.weekday) ?? 0
        return (0..<7).map { step in
            let date = DayArithmetic.adding(step, to: start)
            let weekday = DayArithmetic.weekdayInitials[(todayIndex + ((offset + step) % 7 + 7)) % 7]
            return CalendarDay(date: date, weekday: weekday, hasBillDue: dueDates.contains(date))
        }
    }

    /// The bill-calendar week: the week the next bill lands in.
    public var upcomingBillWeek: [CalendarDay] {
        billWeek(startingAt: bills.map(\.due).min() ?? period.today)
    }

    // MARK: Net worth

    public var netWorth: Money { accounts.sum(\.balance) }

    public var netWorthYearChange: Money { netWorth - (netWorthHistory.first ?? netWorth) }

    /// Snapshot three months before the latest one.
    private var netWorthQuarterAgo: Money {
        let index = netWorthHistory.count - 4
        return netWorthHistory.indices.contains(index) ? netWorthHistory[index] : netWorth
    }

    /// Change over the past three months in whole dollars.
    public var netWorthQuarterChange: Money { (netWorth - netWorthQuarterAgo).roundedToDollars }

    public var netWorthQuarterPercent: Double {
        netWorthQuarterChange.fraction(of: netWorthQuarterAgo) * 100
    }

    /// Account groups that hold at least one account, in balance-sheet order.
    public var accountGroups: [AccountGroupTotal] {
        AccountGroup.allCases.compactMap { group in
            let members = accounts.filter { $0.group == group }
            guard !members.isEmpty else { return nil }
            return AccountGroupTotal(group: group, total: members.sum(\.balance), count: members.count)
        }
    }

    /// Net worth history trimmed to a chart range.
    public func netWorthHistory(for range: NetWorthRange) -> [Money] {
        Array(netWorthHistory.suffix(range.snapshots(available: netWorthHistory.count)))
    }

    // MARK: Cash flow

    /// What the latest month kept, and as a share of income.
    public var latestSavings: (amount: Money, percentOfIncome: Double)? {
        cashflow.last.map { ($0.saved, $0.savingsRate) }
    }

    // MARK: Household

    public var sharedTotal: Money { sharedSpend.values.sum() }

    /// Maya's share of shared spending as a percentage of the total.
    public var mayaSharePercent: Double {
        (sharedSpend[.maya] ?? .zero).fraction(of: sharedTotal) * 100
    }

    public var splitShares: [MemberID: Double] {
        SplitCalculator.shares(for: splitPolicy, members: members)
    }

    /// The month's settle-up balance under the household's split.
    public var settleUpBalance: SettleUpBalance {
        SplitCalculator.balance(paid: sharedSpend, policy: splitPolicy, members: members)
    }

    /// What Jordan owes Maya this month (zero if the balance runs the other way).
    public var jordanOwes: Money { settleUpBalance.owed(from: .jordan, to: .maya) }

    public var privateAccountCount: Int { sharedAccounts.filter { !$0.shared }.count }
}

/// A category's month at a glance.
public struct BudgetStatus: Hashable, Sendable {
    public let category: Category

    public init(category: Category) {
        self.category = category
    }

    /// Budget plus anything rolled over from last month.
    public var available: Money { category.budget + category.rollover }
    /// Bar fill, clamped to 1.
    public var fraction: Double { min(max(category.spent.fraction(of: available), 0), 1) }
    public var isOver: Bool { category.spent > available }
    public var remaining: Money { available - category.spent }
    /// How far over the monthly budget the category ran (ignores rollover, as the screens do).
    public var overBy: Money { category.spent - category.budget }

    /// The note beside the category name: "$12 over", "+$42 rollover" or "$102 left".
    public var note: BudgetNote {
        if isOver { return .over(overBy) }
        if category.rollover > .zero { return .rollover(category.rollover) }
        return .left(remaining)
    }
}

public enum BudgetNote: Hashable, Sendable {
    case over(Money)
    case rollover(Money)
    case left(Money)

    public var text: String {
        switch self {
        case let .over(amount): "\(MoneyFormat.money(amount, decimals: 0)) over"
        case let .rollover(amount): "+\(MoneyFormat.money(amount, decimals: 0)) rollover"
        case let .left(amount): "\(MoneyFormat.money(amount, decimals: 0)) left"
        }
    }
}

public struct AccountGroupTotal: Hashable, Sendable, Codable {
    public let group: AccountGroup
    public let total: Money
    public let count: Int

    /// `"1 account"` / `"4 accounts"`.
    public var countLabel: String { "\(count) account\(count == 1 ? "" : "s")" }
}

/// Ranges on the net worth chart. Each shows that many monthly snapshots.
public enum NetWorthRange: String, CaseIterable, Sendable, Codable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    case all = "All"

    public var label: String { rawValue }

    public func snapshots(available: Int) -> Int {
        switch self {
        case .oneMonth: min(2, available)
        case .threeMonths: min(4, available)
        case .oneYear: min(12, available)
        case .all: available
        }
    }
}

/// Year-less day arithmetic for the bill calendar. February is treated as 28 days.
enum DayArithmetic {
    static let monthLengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    static let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let weekdayInitials = ["S", "M", "T", "W", "T", "F", "S"]

    static func weekdayIndex(_ name: String) -> Int? {
        weekdayNames.firstIndex { $0.lowercased() == name.lowercased() }
    }

    static func dayOfYear(_ date: MonthDay) -> Int {
        monthLengths.prefix(date.month - 1).reduce(0, +) + date.day
    }

    /// Days from `start` forward to `end`, wrapping into the next year if `end` is earlier.
    static func days(from start: MonthDay, to end: MonthDay) -> Int {
        let difference = dayOfYear(end) - dayOfYear(start)
        return difference >= 0 ? difference : difference + 365
    }

    static func adding(_ days: Int, to date: MonthDay) -> MonthDay {
        var month = date.month
        var day = date.day + days
        while day > monthLengths[month - 1] {
            day -= monthLengths[month - 1]
            month = month == 12 ? 1 : month + 1
        }
        return MonthDay(month: month, day: day)
    }
}
