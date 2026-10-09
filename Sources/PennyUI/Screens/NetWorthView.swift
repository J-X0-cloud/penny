#if os(iOS)
import PennyCore
import SwiftUI

/// The balance sheet: total, three-month change, a ranged history chart and account groups.
struct NetWorthView: View {
    @Environment(HouseholdStore.self) private var store
    @State private var range: NetWorthRange = .oneYear

    var body: some View {
        let household = store.household
        let groups = household.accountGroups
        ScreenScroll {
            ScreenHeader(eyebrow: "All accounts · updated 12m ago", title: "Net worth") {
                Pill(accessibilityLabel: "Filter accounts") {
                    PennyIcon(name: .sliders, color: Theme.ink, size: 16)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(household.netWorth.whole)
                    .font(Typography.serif(38))
                    .tracking(-0.8)
                    .foregroundStyle(Theme.ink)
                HStack(spacing: 4) {
                    let rising = household.netWorthQuarterChange >= .zero
                    PennyIcon(name: rising ? .up : .down, color: rising ? Theme.green : Theme.rose, size: 16, lineWidth: 2.2)
                    Text(household.netWorthQuarterChange.magnitude.whole)
                        .font(Typography.sans(14, weight: .semibold))
                        .foregroundStyle(rising ? Theme.green : Theme.rose)
                    Text("(\(MoneyFormat.percent(household.netWorthQuarterPercent, decimals: 1))) past 3 months")
                        .font(Typography.sans(13))
                        .foregroundStyle(Theme.muted)
                }
            }

            NetWorthChartView(history: household.netWorthHistory(for: range))

            Picker("Range", selection: $range) {
                ForEach(NetWorthRange.allCases, id: \.self) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 0) {
                ForEach(groups, id: \.group) { group in
                    ListRow(
                        chip: Chip(icon: group.group.icon),
                        title: { Text(group.group.rawValue) },
                        subtitle: group.countLabel,
                        amount: group.total.whole,
                        negative: group.total.isNegative,
                        showsDivider: group.group != groups.last?.group
                    )
                }
            }
        }
    }
}
#endif
