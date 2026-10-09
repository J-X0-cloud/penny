#if os(iOS)
import PennyCore
import SwiftUI

/// Recurring bills: the 30-day total, a week calendar to filter by day, and price-change alerts.
struct BillsView: View {
    @Environment(HouseholdStore.self) private var store
    @State private var selectedDay: MonthDay?

    var body: some View {
        let household = store.household
        let week = household.upcomingBillWeek
        let visible = selectedDay.map { household.bills(dueOn: $0) } ?? Array(household.bills.prefix(6))
        ScreenScroll {
            ScreenHeader(eyebrow: "Next 30 days · \(household.bills.count) bills", title: "Recurring") {
                Pill(accessibilityLabel: "Add a bill") {
                    PennyIcon(name: .plus, color: Theme.ink, size: 16)
                }
            }
            Text(household.billsTotal.formatted)
                .font(Typography.serif(38))
                .tracking(-0.8)
                .foregroundStyle(Theme.ink)

            Card {
                Text(week.first?.date.longMonth ?? "")
                    .font(Typography.sans(12, weight: .semibold))
                    .foregroundStyle(Theme.muted)
                    .padding(.bottom, 6)
                HStack {
                    ForEach(week) { day in
                        DayButton(day: day, isSelected: selectedDay == day.date) {
                            selectedDay = selectedDay == day.date ? nil : day.date
                        }
                        if day.id != week.last?.id { Spacer(minLength: 0) }
                    }
                }
            }

            if let increase = household.priceIncrease, let change = increase.priceChange {
                HStack(alignment: .top, spacing: 10) {
                    PennyIcon(name: .bell, color: Theme.copper, size: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(increase.name) went up \(change.formatted)")
                            .font(Typography.sans(14, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Text("Now \(increase.amount.formatted) a month, starting \(increase.due.label).")
                            .font(Typography.sans(12.5))
                            .foregroundStyle(Theme.ink2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(Theme.copperLight, in: RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
                .accessibilityElement(children: .combine)
            }

            VStack(spacing: 0) {
                if visible.isEmpty, let day = selectedDay {
                    Text("Nothing due on \(day.label).")
                        .font(Typography.sans(14))
                        .foregroundStyle(Theme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    ForEach(visible) { bill in
                        BillRow(bill: bill, showsDivider: bill.id != visible.last?.id)
                    }
                }
            }
            .animation(.default, value: selectedDay)
        }
    }
}

private struct DayButton: View {
    let day: CalendarDay
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(day.weekday)
                    .font(Typography.sans(11))
                    .foregroundStyle(isSelected ? .white.opacity(0.75) : Theme.muted)
                Text(String(day.date.day))
                    .font(Typography.sans(15, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Theme.ink)
                Circle()
                    .fill(isSelected ? .white : Theme.copper)
                    .frame(width: 5, height: 5)
                    .opacity(day.hasBillDue ? 1 : 0)
            }
            .frame(width: 40)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.violet : .clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(day.date.label)\(day.hasBillDue ? ", bill due" : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
#endif
