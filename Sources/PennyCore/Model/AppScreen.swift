/// The iPhone app's five tabs, in tab-bar order. The web preview walks through the same list.
public enum AppScreen: String, CaseIterable, Identifiable, Codable, Sendable {
    case home
    case budgets
    case bills
    case netWorth = "networth"
    case household

    public var id: String { rawValue }

    /// Tab-bar label.
    public var title: String {
        switch self {
        case .home: "Home"
        case .budgets: "Budgets"
        case .bills: "Bills"
        case .netWorth: "Net worth"
        case .household: "Household"
        }
    }

    public var icon: IconName {
        switch self {
        case .home: .grid
        case .budgets: .pie
        case .bills: .repeat
        case .netWorth: .trend
        case .household: .users
        }
    }
}
