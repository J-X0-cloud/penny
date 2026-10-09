import PennyCore

/// The browser-framed web app overview, built from the same household as the phone screens.
extension SiteRenderer {
    private struct Kpi {
        enum Tone: String { case good, flat }

        let label: String
        let value: String
        let delta: HTML
        let tone: Tone
        let trend: [Double]
        let color: String
    }

    private static let sidebar: [IconLabel] = [
        IconLabel(icon: .grid, label: "Overview"),
        IconLabel(icon: .list, label: "Transactions"),
        IconLabel(icon: .pie, label: "Budgets"),
        IconLabel(icon: .repeat, label: "Recurring"),
        IconLabel(icon: .trend, label: "Investments"),
        IconLabel(icon: .users, label: "Household"),
        IconLabel(icon: .target, label: "Goals"),
    ]

    private var kpis: [Kpi] {
        let period = household.period
        let previousMonth = household.cashflow.dropLast().last?.month ?? "last month"
        let thisMonthTrend = household.spendThisMonth.enumerated().filter { $0.offset % 2 == 0 }.map(\.element.dollars)
        return [
            Kpi(
                label: "Spent this month", value: money(household.totalSpent),
                delta: icon(household.versusLastMonthPercent <= 0 ? .down : .up)
                    + .text(" \(MoneyFormat.fixed(abs(household.versusLastMonthPercent), decimals: 1))% vs \(previousMonth)"),
                tone: household.versusLastMonthPercent <= 0 ? .good : .flat, trend: thisMonthTrend, color: Palette.violet.css
            ),
            Kpi(
                label: "Income", value: money(household.monthlyIncome), delta: .text("2 paychecks"), tone: .flat,
                trend: household.cashflow.map(\.income.dollars), color: Palette.green.css
            ),
            Kpi(
                label: "Left to budget", value: money(household.leftToBudget), delta: .text("\(period.daysLeft) days left"),
                tone: .flat, trend: leftToBudgetTrend, color: Palette.copper.css
            ),
            Kpi(
                label: "Net worth", value: money(household.netWorth, decimals: 0),
                delta: icon(.up) + .text(" \(money(household.netWorthQuarterChange, decimals: 0)) · 3 mo"),
                tone: .good, trend: household.netWorthHistory.map(\.dollars), color: Palette.violet.css
            ),
        ]
    }

    /// What was left to budget at the end of each of the last five weeks, ending today.
    private var leftToBudgetTrend: [Double] {
        let budget = household.totalBudget.dollars
        let samples = stride(from: 0, to: household.period.day, by: 5).map { day -> Double in
            day == 0 ? budget : budget - household.spendThisMonth[day - 1].dollars
        }
        return samples + [household.leftToBudget.dollars]
    }

    func webDashboard() -> HTML {
        let period = household.period
        let lastMonth = household.cashflow.dropLast().last.map { month in
            MonthDay.longNames.first { $0.hasPrefix(month.month) } ?? month.month
        } ?? "Last month"
        return div(
            .class("browser"), .role("img"),
            .aria("label", "Penny web dashboard: \(period.month) overview with spending chart, budgets, transactions and upcoming bills")
        ) {
            div(.class("bbar")) {
                italic()
                italic()
                italic()
                span(.class("url")) {
                    icon(.lock)
                    " app.pennyapp.com/overview"
                }
            }
            div(.class("dash")) {
                aside(.class("dside")) {
                    wordmark(.sm)
                    nav {
                        for (index, item) in Self.sidebar.enumerated() {
                            span(.class(index == 0 ? "on" : nil)) {
                                icon(item.icon)
                                item.label
                            }
                        }
                    }
                    div(.class("dside-f")) {
                        small { "Viewing" }
                        span(.class("vw")) {
                            coupleAvatars(small: true)
                            "Household "
                            icon(.chevd)
                        }
                    }
                }
                div(.class("dmain")) {
                    div(.class("dtop")) {
                        div {
                            small { period.todayLong }
                            h3 { "Overview" }
                        }
                        div(.class("dctl")) {
                            span(.class("seg")) {
                                span(.class("on")) { "Month" }
                                span { "Quarter" }
                                span { "Year" }
                            }
                            span(.class("dpill")) {
                                icon(.calendar)
                                " \(period.shortMonth) 1 – \(period.shortMonth) \(period.days)"
                            }
                            span(.class("dbtn")) {
                                icon(.plus)
                                " Add account"
                            }
                        }
                    }
                    div(.class("kpis")) {
                        for kpi in kpis {
                            div(.class("kpi")) {
                                small { kpi.label }
                                b { kpi.value }
                                div(.class("kpi-f")) {
                                    span(.class("dlt", kpi.tone.rawValue)) { kpi.delta }
                                    sparkline(kpi.trend, color: kpi.color)
                                }
                            }
                        }
                    }
                    div(.class("drow")) {
                        div(.class("dcard", "span2")) {
                            div(.class("dch")) {
                                div {
                                    b { "Spending this month" }
                                    small { "\(money(household.totalSpent)) spent · \(money(household.underPace, decimals: 0)) under budget pace" }
                                }
                                span(.class("lg")) {
                                    span {
                                        italic(.class("l1"))
                                        period.month
                                    }
                                    span {
                                        italic(.class("l2"))
                                        lastMonth
                                    }
                                    span {
                                        italic(.class("l3"))
                                        "Budget pace"
                                    }
                                }
                            }
                            div(.class("dchart")) {
                                div(.class("yl")) {
                                    for value in SpendChartGeometry.gridValues.reversed() {
                                        span { value >= 1000 ? MoneyFormat.thousands(Money(dollars: value)) : money(Money(dollars: value), decimals: 0) }
                                    }
                                }
                                div(.class("chart-box", "big")) { spendChart(width: 640, height: 210, axis: true) }
                            }
                            div(.class("xl")) {
                                for label in ["\(period.shortMonth) 1", "5", "10", "15", "20", "25", String(period.days)] {
                                    span { label }
                                }
                            }
                        }
                        div(.class("dcard")) {
                            div(.class("dch")) {
                                div {
                                    b { "Budgets" }
                                    small { "\(money(household.leftToBudget, decimals: 0)) left of \(money(household.totalBudget, decimals: 0))" }
                                }
                                a { "Edit" }
                            }
                            for category in household.categories.prefix(6) {
                                let status = household.budgetStatus(for: category)
                                div(.class("db-row")) {
                                    categoryChip(category.key, small: true)
                                    div(.class("grow")) {
                                        div(.class("bl")) {
                                            b { category.label }
                                            span(.class(status.isOver ? "ov" : nil)) {
                                                "\(money(category.spent, decimals: 0)) / \(money(status.available, decimals: 0))"
                                            }
                                        }
                                        progressBar(fraction: status.fraction, color: status.isOver ? Palette.rose.css : category.foreground.css)
                                    }
                                }
                            }
                        }
                    }
                    div(.class("drow")) {
                        div(.class("dcard", "span2")) {
                            div(.class("dch")) {
                                div {
                                    b { "Recent transactions" }
                                    small { "\(household.reviewQueueCount) waiting for review" }
                                }
                                span(.class("dsearch")) {
                                    icon(.search)
                                    " Search"
                                }
                            }
                            transactionsTable()
                        }
                        div(.class("dcard")) {
                            div(.class("dch")) {
                                div {
                                    b { "Upcoming" }
                                    small { "\(money(household.billsTotal)) over the next 30 days" }
                                }
                                a { "Calendar" }
                            }
                            for bill in household.bills.prefix(5) {
                                div(.class("db-bill")) {
                                    span(.class("dd")) {
                                        small { bill.due.shortMonth }
                                        b { String(bill.due.day) }
                                    }
                                    div(.class("grow")) {
                                        b { bill.name }
                                        small { bill.note }
                                    }
                                    span(.class("amt")) { money(bill.amount) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func transactionsTable() -> HTML {
        table(.class("dtable")) {
            thead {
                tr {
                    th { "Date" }
                    th { "Merchant" }
                    th(.class("hide-s")) { "Category" }
                    th(.class("hide-s", "hide-m")) { "Account" }
                    th(.class("hide-s")) { "By" }
                    th(.class("r")) { "Amount" }
                }
            }
            tbody {
                for transaction in household.transactions {
                    let category = household.category(transaction.category)
                    tr {
                        td(.class("dt")) { household.period.relativeLabel(for: transaction.postedOn) }
                        td {
                            span(.class("mer")) {
                                categoryChip(transaction.category, small: true)
                                transaction.merchant
                            }
                        }
                        td(.class("hide-s")) {
                            span(.class("cat"), .style(["color": category.foreground.css, "background": category.tint.css])) { category.label }
                        }
                        td(.class("hide-s", "hide-m")) { transaction.account }
                        td(.class("hide-s")) { avatar(transaction.paidBy, small: true) }
                        td(.class("r")) { money(-transaction.amount) }
                    }
                }
            }
        }
    }
}
