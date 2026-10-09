#if os(iOS)
import PennyCore
import SwiftUI

/// Today at a glance: spend against budget, pace, upcoming bills and the review queue.
struct HomeView: View {
    @Environment(HouseholdStore.self) private var store
    @Binding var selectedTab: AppScreen

    var body: some View {
        let household = store.household
        let maya = household.member(.maya)
        ScreenScroll {
            ScreenHeader(eyebrow: household.period.todayShort, title: "Good morning, \(maya.name)") {
                Avatar(member: maya)
            }
            hero(household)

            VStack(alignment: .leading, spacing: 0) {
                SectionTitle(title: "Upcoming bills", actionLabel: "See all") { selectedTab = .bills }
                let upcoming = Array(household.bills.prefix(2))
                ForEach(upcoming) { bill in
                    BillRow(bill: bill, showsDivider: bill.id != upcoming.last?.id)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                SectionTitle(title: "To review", badge: household.reviewQueueCount)
                let queue = store.reviewPreview
                if queue.isEmpty {
                    Text("You’re all caught up.")
                        .font(Typography.sans(14))
                        .foregroundStyle(Theme.muted)
                        .padding(.vertical, 12)
                }
                ForEach(queue) { transaction in
                    ReviewRow(transaction: transaction, showsDivider: transaction.id != queue.last?.id)
                }
            }
        }
    }

    private func hero(_ household: Household) -> some View {
        let spent = MoneyFormat.split(household.totalSpent)
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Spent in \(household.period.month)")
                    .font(Typography.sans(13))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text("Household")
                    .font(Typography.sans(11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.16), in: Capsule())
            }
            (Text(spent.dollars) + Text(".\(spent.cents)").font(Typography.serif(24)).foregroundColor(.white.opacity(0.7)))
                .font(Typography.serif(40))
                .tracking(-0.8)
                .foregroundStyle(.white)
                .padding(.top, 2)
                .accessibilityLabel("Spent \(household.totalSpent.formatted)")
            (Text("of \(household.totalBudget.whole) budget · ")
                + Text("\(household.underPace.whole) under pace").font(Typography.sans(13, weight: .semibold)).foregroundColor(Theme.heroAccent))
                .font(Typography.sans(13))
                .foregroundStyle(.white.opacity(0.85))
            SpendChartView(household: household)
                .padding(.top, 10)
                .padding(.bottom, 2)
            HStack {
                Text("\(household.period.shortMonth) 1")
                Spacer()
                Text("15")
                Spacer()
                Text(String(household.period.days))
            }
            .font(Typography.sans(11))
            .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(Theme.heroGradient, in: RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
    }
}

/// A review-queue row. Long-press to file it under another category.
private struct ReviewRow: View {
    @Environment(HouseholdStore.self) private var store
    let transaction: Transaction
    let showsDivider: Bool

    var body: some View {
        let household = store.household
        let category = household.category(transaction.category)
        ListRow(
            chip: Chip(category: category),
            title: { Text(transaction.merchant) },
            subtitle: "\(category.label) · \(household.period.relativeLabel(for: transaction.postedOn))",
            amount: transaction.amount.formatted,
            showsDivider: showsDivider
        )
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                Task { await store.recategorize(transaction, to: transaction.category) }
            } label: {
                Label("Looks right", systemImage: "checkmark")
            }
            Menu("Change category") {
                ForEach(household.categories.filter { $0.key != transaction.category }) { option in
                    Button(option.label) {
                        Task { await store.recategorize(transaction, to: option.key) }
                    }
                }
            }
        }
        .accessibilityHint("Touch and hold to change the category")
    }
}
#endif
