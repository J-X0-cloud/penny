#if os(iOS)
import PennyCore
import SwiftUI

/// Shared spending, the settle-up balance, shared goals and which accounts the household can see.
struct HouseholdView: View {
    @Environment(HouseholdStore.self) private var store
    @State private var showsNewGoal = false
    @State private var isSettling = false

    var body: some View {
        let household = store.household
        let maya = household.member(.maya)
        let jordan = household.member(.jordan)
        ScreenScroll {
            ScreenHeader(eyebrow: "\(maya.name) & \(jordan.name)", title: "Household") {
                CoupleAvatars(members: [maya, jordan])
            }

            Card {
                Text("Shared spending · \(household.period.month)")
                    .font(Typography.sans(13))
                    .foregroundStyle(Theme.muted)
                Text(household.sharedTotal.formatted)
                    .font(Typography.serif(32))
                    .tracking(-0.6)
                    .foregroundStyle(Theme.ink)
                    .padding(.vertical, 4)
                SplitBar(mayaFraction: household.mayaSharePercent / 100)
                    .padding(.top, 4)
                HStack {
                    legend(color: Theme.violet, text: "\(maya.name) \((household.sharedSpend[.maya] ?? .zero).whole)")
                    Spacer()
                    legend(color: Theme.copper, text: "\(jordan.name) \((household.sharedSpend[.jordan] ?? .zero).whole)")
                }
                .padding(.top, 8)
            }

            settleCard(household)

            VStack(alignment: .leading, spacing: 0) {
                SectionTitle(title: "Shared goals", actionLabel: "Add") { showsNewGoal = true }
                ForEach(household.goals.prefix(4)) { goal in
                    GoalRow(goal: goal)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                SectionTitle(title: "Accounts in this household")
                ForEach(household.sharedAccounts) { account in
                    SharedAccountRow(account: account, household: household)
                }
            }
        }
        .alert("New shared goal", isPresented: $showsNewGoal) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Set a target and a date, and Penny works out the monthly amount for both of you.")
        }
    }

    private func legend(color: Color, text: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(text)
                .font(Typography.sans(12.5, weight: .medium))
                .foregroundStyle(Theme.ink2)
        }
    }

    private func settleCard(_ household: Household) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(household.splitPolicy.label(shares: household.splitShares))
                    .font(Typography.sans(12))
                    .foregroundStyle(Theme.violetDark)
                Text(store.settleUpSummary)
                    .font(Typography.sans(15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.opacity)
            }
            Spacer(minLength: 0)
            Button {
                isSettling = true
                Task {
                    await store.settleUp()
                    isSettling = false
                }
            } label: {
                Group {
                    if isSettling {
                        ProgressView().tint(.white)
                    } else {
                        Text(store.isSettled ? "Settled" : "Settle up")
                    }
                }
                .font(Typography.sans(13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(store.isSettled ? Theme.green : Theme.violet, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(store.isSettled || isSettling)
            .sensoryFeedback(.success, trigger: store.isSettled) { _, settled in settled }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Theme.violetLight, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .animation(.default, value: store.isSettled)
    }
}

/// Maya's and Jordan's share of shared spending as two rounded segments.
private struct SplitBar: View {
    let mayaFraction: Double

    var body: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 3
            let usable = max(proxy.size.width - gap, 0)
            HStack(spacing: gap) {
                RoundedRectangle(cornerRadius: 6).fill(Theme.violet).frame(width: usable * CGFloat(min(max(mayaFraction, 0), 1)))
                RoundedRectangle(cornerRadius: 6).fill(Theme.copper)
            }
        }
        .frame(height: 10)
        .accessibilityElement()
        .accessibilityLabel("Maya paid \(Int((mayaFraction * 100).rounded())) percent of shared spending")
    }
}

private struct GoalRow: View {
    let goal: Goal

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ArtworkImage(name: goal.image)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(goal.name)
                        .font(Typography.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text("\(goal.percent)%")
                        .font(Typography.sans(13, weight: .semibold))
                        .foregroundStyle(Theme.copper)
                }
                ProgressBar(fraction: goal.progress, color: Theme.copper)
                Text("\(goal.saved.whole) of \(goal.target.whole) · \(goal.note)")
                    .font(Typography.sans(12))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

private struct SharedAccountRow: View {
    @Environment(HouseholdStore.self) private var store
    let account: SharedAccount
    let household: Household

    var body: some View {
        HStack(spacing: 12) {
            Chip(icon: account.icon)
            VStack(alignment: .leading, spacing: 1) {
                Text(account.name)
                    .font(Typography.sans(15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(account.shared ? "Shared · \(account.institution)" : "\(privateLabel) · \(account.institution)")
                    .font(Typography.sans(12.5))
                    .foregroundStyle(Theme.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Toggle("Share \(account.name)", isOn: Binding(
                get: { account.shared },
                set: { store.setShared($0, accountID: account.id) }
            ))
            .labelsHidden()
            .tint(Theme.violet)
        }
        .padding(.vertical, 8)
    }

    private var privateLabel: String {
        switch account.owner {
        case .both: "Only you"
        case let .member(id): "Only \(household.member(id).name)"
        }
    }
}
#endif
