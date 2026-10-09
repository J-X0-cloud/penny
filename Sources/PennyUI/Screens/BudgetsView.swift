#if os(iOS)
import PennyCore
import SwiftUI

/// The monthly budget ring and per-category bars, with over-budget and rollover states.
struct BudgetsView: View {
    @Environment(HouseholdStore.self) private var store
    @State private var showsAllCategories = false

    var body: some View {
        let household = store.household
        let visible = showsAllCategories ? household.categories : Array(household.categories.prefix(6))
        ScreenScroll {
            ScreenHeader(eyebrow: "Monthly budget", title: "Budgets") {
                Pill(accessibilityLabel: "Change month") {
                    Text(household.period.shortMonth)
                    PennyIcon(name: .chevd, color: Theme.ink, size: 15)
                }
            }

            Card {
                HStack(spacing: 18) {
                    Donut(fraction: household.totalSpent.fraction(of: household.totalBudget)) {
                        Text(household.leftToBudget.whole)
                            .font(Typography.serif(20, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Text("left")
                            .font(Typography.sans(12))
                            .foregroundStyle(Theme.muted)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        LegendRow(swatch: Theme.violet, label: "Spent", value: household.totalSpent.whole)
                        LegendRow(swatch: Theme.track, label: "Budget", value: household.totalBudget.whole)
                        HStack(spacing: 5) {
                            PennyIcon(name: .check, color: Theme.green, size: 14)
                            Text(household.underPace >= .zero ? "\(household.underPace.whole) under pace" : "\(household.underPace.magnitude.whole) over pace")
                                .font(Typography.sans(13, weight: .semibold))
                                .foregroundStyle(household.underPace >= .zero ? Theme.green : Theme.rose)
                        }
                    }
                }
            }

            VStack(spacing: 0) {
                ForEach(visible) { category in
                    BudgetRow(status: household.budgetStatus(for: category))
                }
            }
            .animation(.default, value: showsAllCategories)

            if !showsAllCategories && household.categories.count > visible.count {
                Pill(accessibilityLabel: "Show all categories", action: { showsAllCategories = true }) {
                    Text("Show all \(household.categories.count) categories")
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct LegendRow: View {
    let swatch: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 7) {
            RoundedRectangle(cornerRadius: 3).fill(swatch).frame(width: 9, height: 9)
            Text(label)
                .font(Typography.sans(13))
                .foregroundStyle(Theme.ink2)
            Spacer()
            Text(value)
                .font(Typography.sans(13, weight: .semibold))
                .foregroundStyle(Theme.ink)
        }
    }
}

private struct BudgetRow: View {
    let status: BudgetStatus

    var body: some View {
        let category = status.category
        HStack(alignment: .top, spacing: 12) {
            Chip(category: category)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(category.label)
                        .font(Typography.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text(status.note.text)
                        .font(Typography.sans(12.5, weight: .medium))
                        .foregroundStyle(noteColor)
                }
                ProgressBar(fraction: status.fraction, color: status.isOver ? Theme.rose : Color(category.foreground))
                Text("\(category.spent.whole) of \(status.available.whole)")
                    .font(Typography.sans(12))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var noteColor: Color {
        switch status.note {
        case .over: Theme.rose
        case .rollover: Theme.green
        case .left: Theme.muted
        }
    }
}
#endif
