import PennyCore

/// Feature cards shown beside the copy on the marketing pages.
extension SiteRenderer {
    func accountsCard(limit: Int = 6) -> HTML {
        div(.class("fcard", "fc-acc")) {
            div(.class("fc-h")) {
                b { "Accounts" }
                a { "Manage" }
            }
            for account in household.accounts.prefix(limit) {
                div(.class("fc-row")) {
                    iconChip(account.group == .cash ? .bank : .trend)
                    div(.class("grow")) {
                        b { account.name }
                        small { "\(account.institution) · \(account.updated)" }
                    }
                    span(.class("amt")) { money(account.balance, decimals: 0) }
                }
            }
        }
    }

    func allocationCard() -> HTML {
        div(.class("fcard", "fc-alloc")) {
            div(.class("fc-h")) {
                b { "Allocation" }
                small { "Investments + cash" }
            }
            div(.class("allocbar")) {
                for slice in household.allocation {
                    italic(.style(["width": "\(slice.percent)%", "background": slice.color.css]))
                }
            }
            div(.class("alloc-l")) {
                for slice in household.allocation {
                    span {
                        italic(.style(["background": slice.color.css]))
                        "\(slice.label) "
                        b { "\(slice.percent)%" }
                    }
                }
            }
        }
    }

    func cashflowCard() -> HTML {
        let scaleMax: Money = 11000
        return div(.class("fcard", "fc-cash")) {
            div(.class("fc-h")) {
                b { "Cash flow" }
                span(.class("lg")) {
                    italic(.class("in"))
                    "Income "
                    italic(.class("ex"))
                    "Spending"
                }
            }
            if let savings = household.latestSavings {
                p(.class("cash-n")) {
                    "\(money(savings.amount, decimals: 0)) "
                    small { "saved in \(household.period.month) · \(MoneyFormat.percent(savings.percentOfIncome)) of income" }
                }
            }
            div(.class("cashbars")) {
                for month in household.cashflow {
                    span {
                        italic(.class("in"), .style(["height": percentWidth(month.income.fraction(of: scaleMax))]))
                        italic(.class("ex"), .style(["height": percentWidth(month.spending.fraction(of: scaleMax))]))
                        small { month.month }
                    }
                }
            }
        }
    }

    func goalCard(_ goal: Goal) -> HTML {
        div(.class("goal")) {
            img(src: imageURL(goal.image), width: 120, height: 120)
            div {
                b { goal.name }
                small { goal.note }
            }
            div(.class("bar")) {
                italic(.style(["width": "\(goal.percent)%"]))
            }
            p {
                b { money(goal.saved, decimals: 0) }
                " of \(money(goal.target, decimals: 0))"
            }
        }
    }

    func netWorthCard(dark: Bool = false) -> HTML {
        div(.class("fcard", "fc-nw", dark ? "dk" : nil)) {
            div(.class("fc-h")) {
                b { "Net worth" }
                span(.class("rng")) {
                    span { "3M" }
                    span(.class("on")) { "1Y" }
                    span { "All" }
                }
            }
            p(.class("nw-n")) { money(household.netWorth, decimals: 0) }
            p(.class("nw-d")) {
                icon(.up)
                " \(money(household.netWorthYearChange, decimals: 0)) over 12 months"
            }
            div(.class("chart-box", "nw-chart")) { netWorthChart(width: 520, height: 150, dark: dark) }
            div(.class("ps-axis")) {
                for (index, month) in household.netWorthMonths.enumerated() where index % 2 == 0 {
                    span { month }
                }
            }
        }
    }

    func recurringCard() -> HTML {
        let spotlight = ["streaming", "gym", "car-insurance", "music"].compactMap(household.bill(id:))
        return div(.class("fcard", "fc-rec")) {
            div(.class("fc-h")) {
                b { "Recurring" }
                span(.class("tagc", "v")) { "\(household.recurringFound) found" }
            }
            for bill in spotlight {
                div(.class("fc-row")) {
                    iconChip(bill.icon)
                    div(.class("grow")) {
                        b {
                            bill.name
                            priceChangeFlag(bill)
                        }
                        small { bill.due.label }
                    }
                    span(.class("amt")) { money(bill.amount) }
                }
            }
        }
    }

    func reviewCard() -> HTML {
        let queue = household.transactions.prefix(5)
        return div(.class("fcard", "fc-review")) {
            div(.class("fc-h")) {
                b { "To review" }
                span(.class("count")) { String(queue.count) }
                a { "View all" }
            }
            for transaction in queue {
                div(.class("fc-row")) {
                    categoryChip(transaction.category)
                    div(.class("grow")) {
                        b { transaction.merchant }
                        small { household.category(transaction.category).label }
                    }
                    span(.class("amt")) { money(transaction.amount) }
                }
            }
            div(.class("fc-btn")) {
                icon(.check)
                " Mark all as reviewed"
            }
        }
    }

    func rolloverCard() -> HTML {
        let fun = household.category(.fun)
        let status = household.budgetStatus(for: fun)
        let previousMonth = household.funHistory.dropLast().last?.month ?? ""
        return div(.class("fcard", "fc-roll")) {
            div(.class("fc-h")) {
                categoryChip(.fun)
                b { fun.label }
                span(.class("tagc")) { "+\(money(fun.rollover)) from \(previousMonth)" }
            }
            div(.class("roll-n")) {
                div {
                    small { "Spent" }
                    b { money(fun.spent) }
                }
                div {
                    small { "Budget" }
                    b { money(status.available) }
                }
                div {
                    small { "Left" }
                    b(.class("g")) { money(status.remaining) }
                }
            }
            div(.class("minibars")) {
                for month in household.funHistory {
                    span(.class(month.month == household.period.shortMonth ? "on" : nil)) {
                        italic(.style(["height": "\(Int((month.spent.fraction(of: fun.budget) * 100).rounded(.toNearestOrAwayFromZero)))%"]))
                        small { month.month }
                    }
                }
                // The monthly budget line.
                em(.style(["bottom": "100%"]))
            }
        }
    }

    func ruleCard() -> HTML {
        div(.class("fcard", "fc-rule")) {
            img(src: imageURL("cat-groceries"), width: 56, height: 56)
            div(.class("grow")) {
                small { "New rule learned" }
                b { "Harvest Co-op → Groceries" }
                small { "Applied to 14 past transactions" }
            }
            span(.class("tagc", "v")) {
                icon(.sparkle)
                "Auto"
            }
        }
    }

    func ledgerCard() -> HTML {
        let jordan = memberName(.jordan)
        return div(.class("fcard")) {
            div(.class("fc-h")) {
                b { "Shared this week" }
                span(.class("tagc", "v")) { "\(jordan) owes \(money(household.jordanOwes))" }
            }
            for entry in household.sharedLedger {
                div(.class("fc-row")) {
                    avatar(entry.paidBy, small: true)
                    div(.class("grow")) {
                        b { entry.label }
                        small { "Paid by \(memberName(entry.paidBy)) · split 50/50" }
                    }
                    span(.class("amt")) { money(entry.amount) }
                }
            }
        }
    }

    /// Account list with share switches, mirroring Settings → Household in the app. The site script
    /// flips the switches in place.
    func sharedAccountsCard() -> HTML {
        div(.class("fcard"), .data("shared-accounts", "")) {
            div(.class("fc-h")) {
                b { "Accounts in this household" }
            }
            for account in household.sharedAccounts {
                let privateLabel: String = switch account.owner {
                case .both: "Only you"
                case let .member(id): "Only \(memberName(id))"
                }
                div(.class("fc-row")) {
                    iconChip(account.icon)
                    div(.class("grow")) {
                        b { account.name }
                        small { account.institution }
                    }
                    button(
                        .role("switch"), .aria("checked", account.shared ? "true" : "false"), .aria("label", "Share \(account.name)"),
                        .class("tog", account.shared ? "on" : nil)
                    ) {
                        italic()
                    }
                    span(.class("who"), .data("private-label", privateLabel)) { account.shared ? "Shared" : privateLabel }
                }
            }
        }
    }

    func setupSteps() -> HTML {
        ol(.class("steps")) {
            for (index, step) in HouseholdPageContent.setupSteps.enumerated() {
                li {
                    span(.class("n")) { String(index + 1) }
                    icon(step.icon)
                    h3 { step.title }
                    p { step.body }
                }
            }
        }
    }
}

