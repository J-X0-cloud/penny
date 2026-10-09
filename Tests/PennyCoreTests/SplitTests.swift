import Testing
@testable import PennyCore

@Suite("Household split and settle-up")
struct SplitTests {
    let members = [Member(id: .maya, name: "Maya", monthlyIncome: 6000), Member(id: .jordan, name: "Jordan", monthlyIncome: 4000)]

    @Test func evenSplitMatchesTheSampleHousehold() {
        let balance = SplitCalculator.balance(paid: [.maya: 1352.1, .jordan: 1134.1], policy: .even, members: members)
        #expect(balance.debtor == .jordan)
        #expect(balance.creditor == .maya)
        #expect(balance.amount == 109)
        #expect(balance.owed(from: .jordan, to: .maya) == 109)
        #expect(balance.owed(from: .maya, to: .jordan) == .zero)
    }

    @Test func balanceRunsTheOtherWayWhenMayaPaidLess() {
        let balance = SplitCalculator.balance(paid: [.maya: 100, .jordan: 300], policy: .even, members: members)
        #expect(balance.debtor == .maya)
        #expect(balance.amount == 100)
    }

    @Test func equalPaymentsAreSquare() {
        let balance = SplitCalculator.balance(paid: [.maya: 50, .jordan: 50], policy: .even, members: members)
        #expect(balance == .square)
        #expect(balance.isSettled)
    }

    @Test func oddCentsNeverGoMissing() {
        // $0.01 total: Maya's half rounds up, so Jordan owes nothing and Maya owes nothing either.
        let balance = SplitCalculator.balance(paid: [.maya: 0.01], policy: .even, members: members)
        #expect(balance.isSettled)
    }

    @Test func byIncomeUsesTheIncomeRatio() {
        #expect(SplitCalculator.shares(for: .byIncome, members: members) == [.maya: 0.6, .jordan: 0.4])
        // Total 1000: Maya's share 600, Jordan's 400. Jordan paid 100, so owes 300.
        let balance = SplitCalculator.balance(paid: [.maya: 900, .jordan: 100], policy: .byIncome, members: members)
        #expect(balance.debtor == .jordan)
        #expect(balance.amount == 300)
        #expect(SplitPolicy.byIncome.label(shares: SplitCalculator.shares(for: .byIncome, members: members)) == "Split 60 / 40")
    }

    @Test func byIncomeFallsBackToEvenWithoutIncomes() {
        let unknown = [Member(id: .maya, name: "Maya"), Member(id: .jordan, name: "Jordan")]
        #expect(SplitCalculator.shares(for: .byIncome, members: unknown) == [.maya: 0.5, .jordan: 0.5])
    }

    @Test func customShareIsClamped() {
        #expect(SplitCalculator.shares(for: .custom(mayaPercent: 70), members: members)[.maya] == 0.7)
        #expect(SplitCalculator.shares(for: .custom(mayaPercent: 140), members: members)[.maya] == 1)
        #expect(SplitPolicy.even.label(shares: [:]) == "Split 50 / 50")
    }

    @Test func balanceFromLedgerEntries() {
        let balance = SplitCalculator.balance(entries: Household.sample.sharedLedger, policy: .even, members: members)
        // Maya paid 144.23, Jordan 60.36; total 204.59, each owes 102.30 / 102.29.
        #expect(balance.debtor == .jordan)
        #expect(balance.amount == 41.93)
    }

    @Test func settlingTheFullBalanceClearsIt() throws {
        let balance = Household.sample.settleUpBalance
        let result = try SettlementService.settle(
            SettleUpRequest(from: .jordan, to: .maya, amount: 109), against: balance, recordedAt: "2026-09-24T09:41:00Z"
        )
        #expect(result.balance.remaining == .zero)
        #expect(result.balance.settled)
        #expect(result.settlement.method == .transfer)
    }

    @Test func partialPaymentLeavesTheRest() throws {
        let result = try SettlementService.settle(
            SettleUpRequest(from: .jordan, to: .maya, amount: 40, method: .cash),
            against: Household.sample.settleUpBalance, recordedAt: "now"
        )
        #expect(result.balance.remaining == 69)
        #expect(!result.balance.settled)
    }

    @Test func paymentInTheWrongDirectionLeavesNothingOutstanding() throws {
        let result = try SettlementService.settle(
            SettleUpRequest(from: .maya, to: .jordan, amount: 10), against: Household.sample.settleUpBalance, recordedAt: "now"
        )
        #expect(result.balance.remaining == .zero)
    }

    @Test func invalidRequestsReportEveryField() {
        #expect(throws: ValidationError(fields: [
            "amount": ["Number must be greater than 0"],
            "to": ["Choose two different members"],
        ])) {
            try SettlementService.settle(
                SettleUpRequest(from: .maya, to: .maya, amount: 0), against: .square, recordedAt: "now"
            )
        }
    }
}
