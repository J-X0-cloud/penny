#if os(iOS) && DEBUG
import PennyCore
import SwiftUI

#Preview("App") {
    PennyRootView(store: HouseholdStore())
}

#Preview("Home") {
    HomeView(selectedTab: .constant(.home))
        .environment(HouseholdStore())
}

#Preview("Budgets") {
    BudgetsView()
        .environment(HouseholdStore())
}

#Preview("Bills") {
    BillsView()
        .environment(HouseholdStore())
}

#Preview("Net worth") {
    NetWorthView()
        .environment(HouseholdStore())
}

#Preview("Household") {
    HouseholdView()
        .environment(HouseholdStore())
}
#endif
