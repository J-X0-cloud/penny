/// Spending categories. The raw value is the stable key used by the API and the database.
public enum CategoryKey: String, CaseIterable, Codable, Sendable {
    case groceries, dining, home, transport, shopping, fun, pets, health, coffee
}

/// A budget category for the current month: what was planned, what was spent and what rolled in.
public struct Category: Identifiable, Hashable, Sendable, Codable {
    public let key: CategoryKey
    public var label: String
    public var icon: IconName
    /// Foreground and tint used for the category chip.
    public var foreground: HexColor
    public var tint: HexColor
    public var spent: Money
    public var budget: Money
    /// Unspent money carried in from last month.
    public var rollover: Money

    public var id: CategoryKey { key }

    public init(
        key: CategoryKey, label: String, icon: IconName, foreground: HexColor, tint: HexColor,
        spent: Money, budget: Money, rollover: Money = .zero
    ) {
        self.key = key
        self.label = label
        self.icon = icon
        self.foreground = foreground
        self.tint = tint
        self.spent = spent
        self.budget = budget
        self.rollover = rollover
    }
}

/// One of the two people in a household. The raw value is the initial shown on avatars.
public enum MemberID: String, CaseIterable, Codable, Sendable, Comparable {
    case maya = "M"
    case jordan = "J"

    public var initial: String { rawValue }

    /// The other member of a two-person household.
    public var partner: MemberID { self == .maya ? .jordan : .maya }

    public static func < (lhs: MemberID, rhs: MemberID) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

public struct Member: Identifiable, Hashable, Sendable, Codable {
    public let id: MemberID
    public var name: String
    /// Monthly take-home pay, used by the by-income split when known.
    public var monthlyIncome: Money?

    public init(id: MemberID, name: String, monthlyIncome: Money? = nil) {
        self.id = id
        self.name = name
        self.monthlyIncome = monthlyIncome
    }

    public var initial: String { id.initial }
}

public struct Transaction: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var merchant: String
    public var category: CategoryKey
    public var amount: Money
    public var postedOn: MonthDay
    public var account: String
    public var paidBy: MemberID
    /// Whether someone has confirmed the category from the review queue.
    public var reviewed: Bool

    public init(
        id: String, merchant: String, category: CategoryKey, amount: Money, postedOn: MonthDay,
        account: String, paidBy: MemberID, reviewed: Bool = false
    ) {
        self.id = id
        self.merchant = merchant
        self.category = category
        self.amount = amount
        self.postedOn = postedOn
        self.account = account
        self.paidBy = paidBy
        self.reviewed = reviewed
    }
}

public struct Bill: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var name: String
    public var icon: IconName
    public var amount: Money
    public var due: MonthDay
    public var note: String
    /// Set when the amount changed since the last charge.
    public var priceChange: Money?

    public init(
        id: String, name: String, icon: IconName, amount: Money, due: MonthDay, note: String,
        priceChange: Money? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.amount = amount
        self.due = due
        self.note = note
        self.priceChange = priceChange
    }

    /// The amount went up since the previous charge.
    public var increased: Bool { (priceChange ?? .zero) > .zero }
}

/// Balance-sheet sections, in the order the net worth screen lists them.
public enum AccountGroup: String, CaseIterable, Codable, Sendable {
    case cash = "Cash"
    case investments = "Investments"
    case otherAssets = "Other assets"
    case liabilities = "Liabilities"

    /// Icon used for the group row on the net worth screen.
    public var icon: IconName {
        switch self {
        case .cash: .wallet
        case .investments: .trend
        case .otherAssets: .car
        case .liabilities: .card
        }
    }
}

public struct Account: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var group: AccountGroup
    public var name: String
    public var institution: String
    /// Positive for assets, negative for what is owed.
    public var balance: Money
    /// Human-readable sync age, e.g. `"2h ago"`.
    public var updated: String

    public init(id: String, group: AccountGroup, name: String, institution: String, balance: Money, updated: String) {
        self.id = id
        self.group = group
        self.name = name
        self.institution = institution
        self.balance = balance
        self.updated = updated
    }
}

public struct Goal: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var name: String
    /// Image asset name without extension; the web serves it from `/images/<name>.webp`.
    public var image: String
    public var saved: Money
    public var target: Money
    public var note: String

    public init(id: String, name: String, image: String, saved: Money, target: Money, note: String) {
        self.id = id
        self.name = name
        self.image = image
        self.saved = saved
        self.target = target
        self.note = note
    }

    /// Progress toward the target, clamped to 0...1.
    public var progress: Double { min(max(saved.fraction(of: target), 0), 1) }
    /// Whole-number percentage, as shown next to the bar.
    public var percent: Int { Int((saved.fraction(of: target) * 100).rounded(.toNearestOrAwayFromZero)) }
    public var remaining: Money { max(target - saved, .zero) }
}

public struct CashflowMonth: Hashable, Sendable, Codable {
    public let month: String
    public var income: Money
    public var spending: Money

    public init(month: String, income: Money, spending: Money) {
        self.month = month
        self.income = income
        self.spending = spending
    }

    public var saved: Money { income - spending }
    public var savingsRate: Double { saved.fraction(of: income) * 100 }
}

/// Spend in one category for one month.
public struct MonthSpend: Hashable, Sendable, Codable {
    public let month: String
    public var spent: Money

    public init(month: String, spent: Money) {
        self.month = month
        self.spent = spent
    }
}

public struct AllocationSlice: Hashable, Sendable, Codable {
    public let label: String
    public var percent: Int
    public var color: HexColor

    public init(label: String, percent: Int, color: HexColor) {
        self.label = label
        self.percent = percent
        self.color = color
    }
}

/// Who an account belongs to inside a household.
public enum AccountOwner: Hashable, Sendable, Codable {
    case both
    case member(MemberID)
}

/// An account as listed in Settings → Household, with its share switch.
public struct SharedAccount: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var name: String
    public var institution: String
    public var owner: AccountOwner
    public var icon: IconName
    public var shared: Bool

    public init(id: String, name: String, institution: String, owner: AccountOwner, icon: IconName, shared: Bool) {
        self.id = id
        self.name = name
        self.institution = institution
        self.owner = owner
        self.icon = icon
        self.shared = shared
    }
}

/// A shared purchase on the household's running tab.
public struct LedgerEntry: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var label: String
    public var paidBy: MemberID
    public var amount: Money

    public init(id: String, label: String, paidBy: MemberID, amount: Money) {
        self.id = id
        self.label = label
        self.paidBy = paidBy
        self.amount = amount
    }
}

/// A day on the bill calendar strip.
public struct CalendarDay: Hashable, Sendable, Identifiable {
    public let date: MonthDay
    /// Single-letter weekday, `"W"`.
    public let weekday: String
    public let hasBillDue: Bool

    public var id: MonthDay { date }

    public init(date: MonthDay, weekday: String, hasBillDue: Bool) {
        self.date = date
        self.weekday = weekday
        self.hasBillDue = hasBillDue
    }
}
