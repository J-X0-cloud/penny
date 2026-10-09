import PennyCore

/// The static iPhone mockups used across the marketing pages, rendered from the same household as
/// the native app.
extension SiteRenderer {
    enum PhoneVariant: String {
        case front, back, solo
    }

    func phone(_ screen: AppScreen, variant: PhoneVariant? = nil) -> HTML {
        div(.class("phone", variant?.rawValue), .role("img"), .aria("label", "Penny app, \(screen.title) screen")) {
            div(.class("scr")) {
                span(.class("island"))
                statusBar()
                div(.class("ps-body")) { screenBody(screen) }
                tabBar(active: screen)
                span(.class("homebar"))
            }
        }
    }

    func screenBody(_ screen: AppScreen) -> HTML {
        switch screen {
        case .home: homeScreen()
        case .budgets: budgetsScreen()
        case .bills: billsScreen()
        case .netWorth: netWorthScreen()
        case .household: householdScreen()
        }
    }

    func statusBar() -> HTML {
        div(.class("ps-status")) {
            span { "9:41" }
            span(.class("ps-sys")) {
                svg(Attribute("viewBox", "0 0 18 12"), .ariaHidden()) {
                    svgRect(Attribute("x", "0"), Attribute("y", "8"), Attribute("width", "3"), Attribute("height", "4"), Attribute("rx", "1"))
                    svgRect(Attribute("x", "5"), Attribute("y", "5.5"), Attribute("width", "3"), Attribute("height", "6.5"), Attribute("rx", "1"))
                    svgRect(Attribute("x", "10"), Attribute("y", "3"), Attribute("width", "3"), Attribute("height", "9"), Attribute("rx", "1"))
                    svgRect(Attribute("x", "15"), Attribute("y", "0"), Attribute("width", "3"), Attribute("height", "12"), Attribute("rx", "1"))
                }
                svg(Attribute("viewBox", "0 0 16 12"), .ariaHidden()) {
                    svgPath(Attribute(
                        "d",
                        "M8 2.2c2.4 0 4.6.9 6.2 2.5l1.3-1.3A10.6 10.6 0 0 0 8 .3 10.6 10.6 0 0 0 .5 3.4l1.3 1.3A8.8 8.8 0 0 1 8 2.2zm0 3.7c1.4 0 2.7.6 3.6 1.5l1.3-1.3A7 7 0 0 0 8 4a7 7 0 0 0-4.9 2.1l1.3 1.3c1-.9 2.2-1.5 3.6-1.5zm0 3.6c.5 0 .9.2 1.2.5L8 11.2 6.8 10c.3-.3.7-.5 1.2-.5z"
                    ))
                }
                svg(Attribute("viewBox", "0 0 27 12"), .ariaHidden()) {
                    svgRect(
                        Attribute("x", ".5"), Attribute("y", ".5"), Attribute("width", "23"), Attribute("height", "11"), Attribute("rx", "3.2"),
                        Attribute("fill", "none"), Attribute("stroke", "currentColor"), Attribute("opacity", ".45")
                    )
                    svgRect(Attribute("x", "2"), Attribute("y", "2"), Attribute("width", "17"), Attribute("height", "8"), Attribute("rx", "2"))
                    svgRect(
                        Attribute("x", "24.6"), Attribute("y", "4"), Attribute("width", "1.6"), Attribute("height", "4"), Attribute("rx", ".8"),
                        Attribute("opacity", ".5")
                    )
                }
            }
        }
    }

    /// In-phone tab bar. Interactive tab bars render buttons the preview script wires up.
    func tabBar(active: AppScreen, interactive: Bool = false) -> HTML {
        nav(.class("ps-tabs"), .aria("label", "App sections")) {
            for screen in AppScreen.allCases {
                let className = Attribute.class("tb", screen == active ? "on" : nil)
                if interactive {
                    button(className, .data("screen", screen.rawValue)) {
                        icon(screen.icon)
                        italic { screen.title }
                    }
                } else {
                    span(className) {
                        icon(screen.icon)
                        italic { screen.title }
                    }
                }
            }
        }
    }

    // MARK: Rows

    func transactionRow(_ transaction: Transaction, showDate: Bool = false) -> HTML {
        let category = household.category(transaction.category)
        let detail = showDate ? household.period.relativeLabel(for: transaction.postedOn) : transaction.account
        return div(.class("ps-row")) {
            categoryChip(transaction.category)
            div(.class("grow")) {
                b { transaction.merchant }
                small { "\(category.label) · \(detail)" }
            }
            span(.class("amt")) { money(transaction.amount) }
        }
    }

    func priceChangeFlag(_ bill: Bill) -> HTML {
        guard let change = bill.priceChange, change != .zero else { return .empty }
        return HTML.text(" ") + em(.class("up")) { "+\(money(change))" }
    }

    func billRow(_ bill: Bill) -> HTML {
        div(.class("ps-row")) {
            iconChip(bill.icon)
            div(.class("grow")) {
                b {
                    bill.name
                    priceChangeFlag(bill)
                }
                small { bill.priceChange == nil ? "\(bill.due.label) · \(bill.note)" : bill.due.label }
            }
            span(.class("amt")) { money(bill.amount) }
        }
    }

    // MARK: Screens

    func homeScreen() -> HTML {
        let spent = MoneyFormat.split(household.totalSpent)
        let period = household.period
        return div(.class("ps-pad")) {
            div(.class("ps-top")) {
                div {
                    small { period.todayShort }
                    h4 { "Good morning, \(memberName(.maya))" }
                }
                avatar(.maya)
            }
            div(.class("ps-hero")) {
                div(.class("ps-hero-h")) {
                    small { "Spent in \(period.month)" }
                    span(.class("ps-pill-w")) { "Household" }
                }
                p(.class("ps-big")) {
                    spent.dollars
                    span { ".\(spent.cents)" }
                }
                p(.class("ps-sub")) {
                    "of \(money(household.totalBudget, decimals: 0)) budget · "
                    b { "\(money(household.underPace, decimals: 0)) under pace" }
                }
                div(.class("chart-box", "ps-chart")) { spendChart(width: 260, height: 70, theme: .dark) }
                div(.class("ps-axis")) {
                    span { "\(period.shortMonth) 1" }
                    span { "15" }
                    span { String(period.days) }
                }
            }
            div(.class("ps-sec")) {
                h5 {
                    "Upcoming bills "
                    a { "See all" }
                }
                for bill in household.bills.prefix(2) { billRow(bill) }
            }
            div(.class("ps-sec")) {
                h5 {
                    "To review "
                    span(.class("count")) { String(household.reviewQueueCount) }
                }
                for transaction in household.transactions.prefix(2) { transactionRow(transaction, showDate: true) }
            }
        }
    }

    func budgetsScreen() -> HTML {
        div(.class("ps-pad")) {
            div(.class("ps-top")) {
                div {
                    small { "Monthly budget" }
                    h4 { "Budgets" }
                }
                span(.class("ps-pill")) {
                    "\(household.period.shortMonth) "
                    icon(.chevd)
                }
            }
            div(.class("ps-ring")) {
                div(.class("ring-wrap")) {
                    donut(fraction: household.totalSpent.fraction(of: household.totalBudget), size: 92, stroke: 10)
                    div(.class("ring-c")) {
                        b { money(household.leftToBudget, decimals: 0) }
                        small { "left" }
                    }
                }
                div(.class("ring-leg")) {
                    p {
                        italic(.style(["background": Palette.violet.css]))
                        "Spent "
                        b { money(household.totalSpent, decimals: 0) }
                    }
                    p {
                        italic(.style(["background": Palette.track.css]))
                        "Budget "
                        b { money(household.totalBudget, decimals: 0) }
                    }
                    p(.class("ok")) {
                        icon(.check)
                        " \(money(household.underPace, decimals: 0)) under pace"
                    }
                }
            }
            div(.class("ps-sec", "tight")) {
                for category in household.categories.prefix(6) {
                    budgetRow(household.budgetStatus(for: category))
                }
            }
        }
    }

    private func budgetRow(_ status: BudgetStatus) -> HTML {
        let category = status.category
        return div(.class("ps-bud")) {
            categoryChip(category.key)
            div(.class("grow")) {
                div(.class("bl")) {
                    b { category.label }
                    switch status.note {
                    case .over: em(.class("ov")) { status.note.text }
                    case .rollover: em(.class("ro")) { status.note.text }
                    case .left: em { status.note.text }
                    }
                }
                progressBar(fraction: status.fraction, color: status.isOver ? Palette.rose.css : category.foreground.css)
                small { "\(money(category.spent, decimals: 0)) of \(money(status.available, decimals: 0))" }
            }
        }
    }

    func billsScreen() -> HTML {
        let week = household.upcomingBillWeek
        return div(.class("ps-pad")) {
            div(.class("ps-top")) {
                div {
                    small { "Next 30 days · \(household.bills.count) bills" }
                    h4 { "Recurring" }
                }
                span(.class("ps-pill")) { icon(.plus) }
            }
            p(.class("ps-big", "dark")) { money(household.billsTotal) }
            div(.class("ps-week")) {
                p { week.first?.date.longMonth ?? "" }
                div {
                    for (offset, day) in week.enumerated() {
                        span(.class(offset == 0 ? "on" : nil)) {
                            small { day.weekday }
                            b { String(day.date.day) }
                            if day.hasBillDue { italic() }
                        }
                    }
                }
            }
            if let increase = household.priceIncrease, let change = increase.priceChange {
                div(.class("ps-alert")) {
                    icon(.bell)
                    p {
                        b { "\(increase.name) went up \(money(change))" }
                        small { "Now \(money(increase.amount)) a month, starting \(increase.due.label)." }
                    }
                }
            }
            div(.class("ps-sec", "tight")) {
                for bill in household.bills.prefix(6) { billRow(bill) }
            }
        }
    }

    func netWorthScreen() -> HTML {
        div(.class("ps-pad")) {
            div(.class("ps-top")) {
                div {
                    small { "All accounts · updated 12m ago" }
                    h4 { "Net worth" }
                }
                span(.class("ps-pill")) { icon(.sliders) }
            }
            p(.class("ps-big", "dark")) { money(household.netWorth, decimals: 0) }
            p(.class("ps-delta")) {
                icon(.up)
                " \(money(household.netWorthQuarterChange, decimals: 0)) "
                span { "(\(MoneyFormat.percent(household.netWorthQuarterPercent, decimals: 1))) past 3 months" }
            }
            div(.class("chart-box", "ps-nw")) { netWorthChart(width: 260, height: 96) }
            div(.class("ps-range")) {
                for range in NetWorthRange.allCases {
                    span(.class(range == .oneYear ? "on" : nil)) { range.label }
                }
            }
            div(.class("ps-sec", "tight")) {
                for group in household.accountGroups {
                    div(.class("ps-row")) {
                        iconChip(group.group.icon)
                        div(.class("grow")) {
                            b { group.group.rawValue }
                            small { group.countLabel }
                        }
                        span(.class("amt", group.total.isNegative ? "neg" : nil)) { money(group.total, decimals: 0) }
                    }
                }
            }
        }
    }

    func householdScreen() -> HTML {
        let maya = memberName(.maya)
        let jordan = memberName(.jordan)
        let mayaShare = household.mayaSharePercent
        return div(.class("ps-pad")) {
            div(.class("ps-top")) {
                div {
                    small { "\(maya) & \(jordan)" }
                    h4 { "Household" }
                }
                coupleAvatars()
            }
            div(.class("ps-card")) {
                small { "Shared spending · \(household.period.month)" }
                p(.class("ps-big", "dark", "sm")) { money(household.sharedTotal) }
                div(.class("split")) {
                    italic(.style(["width": "\(Int(mayaShare.rounded(.toNearestOrAwayFromZero)))%"]))
                    italic(.style(["width": "\(Int((100 - mayaShare).rounded(.toNearestOrAwayFromZero)))%"]))
                }
                div(.class("split-l")) {
                    span {
                        italic(.class("dm"))
                        "\(maya) \(money(household.sharedSpend[.maya] ?? .zero, decimals: 0))"
                    }
                    span {
                        italic(.class("dj"))
                        "\(jordan) \(money(household.sharedSpend[.jordan] ?? .zero, decimals: 0))"
                    }
                }
            }
            div(.class("ps-settle")) {
                div {
                    small { household.splitPolicy.label(shares: household.splitShares) }
                    b { "\(jordan) owes you \(money(household.jordanOwes))" }
                }
                span(.class("ps-btn")) { "Settle up" }
            }
            div(.class("ps-sec", "tight")) {
                h5 {
                    "Shared goals "
                    a { "Add" }
                }
                for goal in household.goals.prefix(4) {
                    div(.class("ps-goal")) {
                        img(src: imageURL(goal.image), width: 40, height: 40)
                        div(.class("grow")) {
                            div(.class("bl")) {
                                b { goal.name }
                                em { "\(goal.percent)%" }
                            }
                            div(.class("bar")) {
                                italic(.style(["width": "\(goal.percent)%", "background": Palette.copper.css]))
                            }
                            small { "\(money(goal.saved, decimals: 0)) of \(money(goal.target, decimals: 0))" }
                        }
                    }
                }
            }
        }
    }
}
