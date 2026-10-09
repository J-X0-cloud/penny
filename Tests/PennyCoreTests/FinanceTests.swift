import Testing
@testable import PennyCore

/// The sample household's derived numbers. These are the figures printed on the site, the phone
/// screens and the API, so a change here is a visible product change.
@Suite("Household finance")
struct FinanceTests {
    let household = Household.sample

    @Test func spendingTotals() {
        #expect(household.totalSpent == 1708.42)
        #expect(household.totalBudget == 2250)
        #expect(household.leftToBudget == 541.58)
        // The cumulative series ends on the same figure as the category totals.
        #expect(household.spendThisMonth.last == household.totalSpent)
    }

    @Test func budgetPace() {
        #expect(household.budgetPace == 1800)
        #expect(household.underPace == 92)
    }

    @Test func versusLastMonth() {
        #expect(household.lastMonthAtToday == 1759.43)
        #expect(MoneyFormat.fixed(household.versusLastMonthPercent, decimals: 1) == "-2.9")
    }

    @Test func billsTotalAndPriceIncrease() {
        #expect(household.billsTotal == 2572.40)
        #expect(household.priceIncrease?.id == "streaming")
        #expect(household.priceIncrease?.priceChange == 2)
    }

    @Test func netWorth() {
        #expect(household.netWorth == 140_826.47)
        #expect(household.netWorthYearChange == 17_850.47)
        #expect(household.netWorthQuarterChange == 5231)
        #expect(MoneyFormat.percent(household.netWorthQuarterPercent, decimals: 1) == "3.9%")
    }

    @Test func accountGroupsInBalanceSheetOrder() {
        let groups = household.accountGroups
        #expect(groups.map(\.group) == [.cash, .investments, .otherAssets, .liabilities])
        #expect(groups.map(\.count) == [2, 4, 1, 3])
        #expect(groups[0].total == 24_860.65)
        #expect(groups[3].total == -22_842.55)
        #expect(groups.sum(\.total) == household.netWorth)
        #expect(groups[2].countLabel == "1 account")
        #expect(groups[1].countLabel == "4 accounts")
    }

    @Test func emptyGroupsAreLeftOut() {
        var trimmed = household
        trimmed.accounts.removeAll { $0.group == .otherAssets }
        #expect(!trimmed.accountGroups.map(\.group).contains(.otherAssets))
    }

    @Test func budgetStatusUnderOverAndRollover() {
        let dining = household.budgetStatus(for: household.category(.dining))
        #expect(dining.isOver)
        #expect(dining.fraction == 1)
        #expect(dining.note == .over(12.75))
        #expect(dining.note.text == "$13 over")

        let fun = household.budgetStatus(for: household.category(.fun))
        #expect(fun.available == 222.33)
        #expect(!fun.isOver)
        #expect(fun.note.text == "+$42 rollover")

        let groceries = household.budgetStatus(for: household.category(.groceries))
        #expect(groceries.remaining == 101.80)
        #expect(groceries.note.text == "$102 left")
        #expect(abs(groceries.fraction - 548.2 / 650) < 1e-9)
    }

    @Test func householdShares() {
        #expect(household.sharedTotal == 2486.20)
        #expect(household.jordanOwes == 109)
        #expect(Int(household.mayaSharePercent.rounded()) == 54)
        #expect(household.privateAccountCount == 2)
    }

    @Test func latestSavings() throws {
        let savings = try #require(household.latestSavings)
        #expect(savings.amount == 3870)
        #expect(MoneyFormat.percent(savings.percentOfIncome) == "39%")
    }

    @Test func billWeekStartsOnTheFirstDueDateWithRealWeekdays() {
        let week = household.upcomingBillWeek
        #expect(week.map(\.date.day) == [1, 2, 3, 4, 5, 6, 7])
        #expect(week.map(\.weekday) == ["W", "T", "F", "S", "S", "M", "T"])
        #expect(week.map(\.hasBillDue) == [true, false, true, false, true, false, false])
    }

    @Test func billWeekRollsAcrossMonthEnds() {
        let week = household.billWeek(startingAt: MonthDay(month: 9, day: 28))
        #expect(week.map(\.date.label) == ["Sep 28", "Sep 29", "Sep 30", "Oct 1", "Oct 2", "Oct 3", "Oct 4"])
        #expect(week[0].weekday == "S")
    }

    @Test func billsDueOnADay() {
        #expect(household.bills(dueOn: MonthDay(month: 10, day: 3)).map(\.id) == ["electric"])
        #expect(household.bills(dueOn: MonthDay(month: 10, day: 2)).isEmpty)
    }

    @Test(arguments: [(NetWorthRange.oneMonth, 2), (.threeMonths, 4), (.oneYear, 12), (.all, 12)])
    func netWorthRanges(range: NetWorthRange, count: Int) {
        let history = household.netWorthHistory(for: range)
        #expect(history.count == count)
        #expect(history.last == household.netWorthHistory.last)
    }

    @Test func goals() {
        let home = household.goals[0]
        #expect(home.percent == 48)
        #expect(home.remaining == 41_600)
        #expect(household.goals[1].percent == 64)
    }

    @Test func periodLabels() {
        #expect(household.period.todayLong == "Wednesday, September 24")
        #expect(household.period.todayShort == "Wednesday, Sep 24")
        #expect(household.period.daysLeft == 6)
        #expect(household.period.relativeLabel(for: MonthDay(month: 9, day: 24)) == "Today")
        #expect(household.period.relativeLabel(for: MonthDay(month: 9, day: 23)) == "Sep 23")
    }

    @Test func monthDayParsing() {
        #expect(MonthDay(label: "Oct 1") == MonthDay(month: 10, day: 1))
        #expect(MonthDay(label: "September 24") == MonthDay(month: 9, day: 24))
        #expect(MonthDay(label: "Oct") == nil)
        #expect(MonthDay(label: "Foo 3") == nil)
    }
}
