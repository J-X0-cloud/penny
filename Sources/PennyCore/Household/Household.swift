/// Everything Penny knows about one household for the current month. Every screen, page and API
/// response is derived from a value of this type (see `Household+Finance.swift`), so the phone, the
/// site and the dashboard always agree.
public struct Household: Hashable, Sendable, Codable {
    public var name: String
    public var members: [Member]
    public var period: BudgetPeriod
    public var categories: [Category]
    public var transactions: [Transaction]
    /// Transactions waiting for a category check.
    public var reviewQueueCount: Int
    public var bills: [Bill]
    /// Recurring charges Penny detected in the last 90 days.
    public var recurringFound: Int
    public var accounts: [Account]
    /// Month labels for `netWorthHistory`, oldest first.
    public var netWorthMonths: [String]
    /// Month-end net worth, oldest first.
    public var netWorthHistory: [Money]
    /// Cumulative spend by day for this month, up to today.
    public var spendThisMonth: [Money]
    /// Cumulative spend by day for the whole of last month.
    public var spendLastMonth: [Money]
    public var cashflow: [CashflowMonth]
    public var monthlyIncome: Money
    /// Monthly spend in the "Fun" category, used to illustrate rollovers.
    public var funHistory: [MonthSpend]
    public var allocation: [AllocationSlice]
    /// Shared spending this month by who paid.
    public var sharedSpend: [MemberID: Money]
    public var goals: [Goal]
    public var sharedAccounts: [SharedAccount]
    /// The running tab of shared purchases this week.
    public var sharedLedger: [LedgerEntry]
    public var splitPolicy: SplitPolicy

    public init(
        name: String, members: [Member], period: BudgetPeriod, categories: [Category],
        transactions: [Transaction], reviewQueueCount: Int, bills: [Bill], recurringFound: Int,
        accounts: [Account], netWorthMonths: [String], netWorthHistory: [Money], spendThisMonth: [Money],
        spendLastMonth: [Money], cashflow: [CashflowMonth], monthlyIncome: Money, funHistory: [MonthSpend],
        allocation: [AllocationSlice], sharedSpend: [MemberID: Money], goals: [Goal],
        sharedAccounts: [SharedAccount], sharedLedger: [LedgerEntry], splitPolicy: SplitPolicy
    ) {
        precondition(netWorthMonths.count == netWorthHistory.count, "Every net worth snapshot needs a month label")
        self.name = name
        self.members = members
        self.period = period
        self.categories = categories
        self.transactions = transactions
        self.reviewQueueCount = reviewQueueCount
        self.bills = bills
        self.recurringFound = recurringFound
        self.accounts = accounts
        self.netWorthMonths = netWorthMonths
        self.netWorthHistory = netWorthHistory
        self.spendThisMonth = spendThisMonth
        self.spendLastMonth = spendLastMonth
        self.cashflow = cashflow
        self.monthlyIncome = monthlyIncome
        self.funHistory = funHistory
        self.allocation = allocation
        self.sharedSpend = sharedSpend
        self.goals = goals
        self.sharedAccounts = sharedAccounts
        self.sharedLedger = sharedLedger
        self.splitPolicy = splitPolicy
    }

    public func member(_ id: MemberID) -> Member {
        guard let member = members.first(where: { $0.id == id }) else {
            preconditionFailure("Household has no member \(id.rawValue)")
        }
        return member
    }

    public func category(_ key: CategoryKey) -> Category {
        guard let category = categories.first(where: { $0.key == key }) else {
            preconditionFailure("Household has no category \(key.rawValue)")
        }
        return category
    }

    public func bill(id: String) -> Bill? {
        bills.first { $0.id == id }
    }
}
