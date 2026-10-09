import PennyCore

/// Page sections shared across the site.
extension SiteRenderer {
    func hero() -> HTML {
        section(.class("hero")) {
            div(.class("wrap", "hero-grid")) {
                div(.class("hero-copy")) {
                    eyebrow("Personal finance for iPhone & the web", dot: true)
                    h1 { headline("Every dollar, ", accent: "right where it belongs.") }
                    p(.class("lede")) {
                        "Penny brings your checking, cards, loans and investments into one calm place, then sorts your spending, watches your bills and keeps your net worth current. For you, or for the whole household."
                    }
                    div(.class("btns")) {
                        linkButton(href: "/pricing", large: true, "Start 14-day free trial")
                        linkButton(href: "/app", variant: .line, large: true, arrow: true, "Tour the app")
                    }
                    p(.class("fine")) { "No card needed to start · Works with most US banks, cards and brokerages" }
                }
                div(.class("hero-vis")) {
                    div(.class("halo"))
                    phone(.budgets, variant: .back)
                    phone(.home, variant: .front)
                    for card in MarketingContent.heroFloats {
                        floatCard(className: card.className, image: imageURL(card.image), title: card.title, note: card.note)
                    }
                }
            }
            div(.class("wrap")) {
                div(.class("trust")) {
                    for point in MarketingContent.trustPoints {
                        span {
                            icon(point.icon)
                            point.label
                        }
                    }
                }
            }
        }
    }

    func floatCard(className: String, image: String, title: String, note: String) -> HTML {
        div(.class("float", className)) {
            img(src: image, width: 52, height: 52)
            div {
                b { title }
                small { note }
            }
        }
    }

    func spendingBento() -> HTML {
        section(.class("sec"), .id("spending")) {
            div(.class("wrap")) {
                sectionHead(
                    eyebrow: "Spending", title: headline("Know where it went, ", accent: "without the spreadsheet."),
                    body: "Penny tags every transaction the moment it posts and learns from each correction you make. You review, it remembers."
                )
                div(.class("bento")) {
                    bentoBox("bx-a", title: "A review queue, not a chore", body: "New transactions land in a short list. Fix a category once and Penny applies it next time.") {
                        ruleCard()
                        reviewCard()
                    }
                    bentoBox("bx-b", title: "Rollovers", body: "Didn’t use the whole budget? Carry it into next month and save up for something bigger.") {
                        rolloverCard()
                    }
                    bentoBox("bx-c", title: "Cash flow", body: "Income against spending, month by month, with what you actually kept.") {
                        cashflowCard()
                    }
                    bentoBox("bx-d", title: "Subscriptions, spotted", body: "The streaming plan that crept up two dollars? Penny noticed.") {
                        recurringCard()
                    }
                }
            }
        }
    }

    func bentoBox(_ variant: String? = nil, title: String, body: String, @HTMLBuilder content: () -> HTML) -> HTML {
        article(.class("bx", variant)) {
            div(.class("bx-t")) {
                h3 { title }
                p { body }
            }
            content()
        }
    }

    func wealthSection() -> HTML {
        section(.class("sec", "sec-dark"), .id("wealth")) {
            div(.class("wrap")) {
                sectionHead(
                    eyebrow: "Net worth", tone: .light, title: headline("Your whole balance sheet, ", accent: "on one screen."),
                    body: "Savings, brokerage, retirement, crypto, the car and every loan against it. No more logging into five apps to add it all up."
                )
                div(.class("wealth")) {
                    div(.class("w-main")) { netWorthCard(dark: true) }
                    div(.class("w-side")) {
                        accountsCard(limit: 4)
                        allocationCard()
                    }
                }
            }
        }
    }

    func householdSection() -> HTML {
        let featured = household.goals.filter { $0.id == "home" || $0.id == "baby" }
        return section(.class("sec"), .id("household")) {
            div(.class("wrap", "split-2")) {
                div(.class("copy")) {
                    eyebrow("Household")
                    h2 { headline("Money is a team sport ", accent: "at home.") }
                    p {
                        "Invite a partner or roommate and choose exactly which accounts you share. Penny splits the shared spending, keeps a running balance of who owes whom and tracks the goals you’re saving for together."
                    }
                    iconList(MarketingContent.householdTicks)
                    linkButton(href: "/household", variant: .line, arrow: true, "How the household view works")
                }
                div(.class("hh-vis")) {
                    phone(.household, variant: .solo)
                    div(.class("goal-stack")) {
                        for goal in featured { goalCard(goal) }
                    }
                }
            }
        }
    }

    func webSection(eyebrow text: String, title: HTML, body: String, @HTMLBuilder extra: () -> HTML = { .empty }) -> HTML {
        section(.class("sec", "sec-tint"), .id("web")) {
            div(.class("wrap")) {
                sectionHead(eyebrow: text, title: title, body: body)
                webDashboard()
                extra()
            }
        }
    }

    func reviews() -> HTML {
        section(.class("sec"), .id("reviews")) {
            div(.class("wrap")) {
                sectionHead(eyebrow: "From early members", title: headline("Less tallying, ", accent: "more deciding."))
                div(.class("quotes")) {
                    for testimonial in MarketingContent.testimonials {
                        figure(.class("quote")) {
                            div(.class("stars"), .aria("label", "5 out of 5")) { "★★★★★" }
                            blockquote { testimonial.quote }
                            figcaption {
                                span(.class("av")) { String(testimonial.name.prefix(1)) }
                                b { testimonial.name }
                                small { testimonial.location }
                            }
                        }
                    }
                }
            }
        }
    }

    func priceTeaser() -> HTML {
        section(.class("sec", "sec-price")) {
            div(.class("wrap")) {
                div(.class("price-teaser")) {
                    div {
                        eyebrow("Pricing")
                        h2 { headline("Honest pricing. ", accent: "You’re the customer, not the product.") }
                        p {
                            "One plan for you, one for the household. No ads, no upsells and no selling your data, because the subscription is the whole business."
                        }
                    }
                    div(.class("pt-cards")) {
                        for plan in PricingContent.teasers {
                            a(.class("pt", plan.highlight ? "hi" : nil), .href("/pricing")) {
                                small { plan.name }
                                b {
                                    plan.monthly
                                    span { "/mo" }
                                }
                                p { plan.note }
                            }
                        }
                    }
                }
            }
        }
    }

    func ctaBand(
        title: String = "Give every dollar a job this month.",
        body: String = "Start a 14-day free trial on iPhone or the web. No card needed to look around."
    ) -> HTML {
        section(.class("cta-band")) {
            div(.class("wrap", "cta-in")) {
                img(src: imageURL("goal-home"), width: 160, height: 160, .class("cta-illo", "a"))
                img(src: imageURL("cat-groceries"), width: 120, height: 120, .class("cta-illo", "b"))
                h2 { title }
                p { body }
                div(.class("btns")) {
                    linkButton(href: "/pricing", variant: .copper, "Start free trial")
                    linkButton(href: "/app", variant: .lineWhite, "Tour the app")
                }
            }
        }
    }

    func featureRow(id: String, eyebrow text: String, title: HTML, body: String, bullets: [Feature], flip: Bool = false, @HTMLBuilder visual: () -> HTML) -> HTML {
        section(.class("frow", flip ? "flip" : nil), .id(id)) {
            div(.class("wrap", "frow-in")) {
                div(.class("copy")) {
                    eyebrow(text)
                    h2 { title }
                    p { body }
                    ul(.class("flist")) {
                        for bullet in bullets {
                            li {
                                icon(bullet.icon)
                                div {
                                    b { bullet.title }
                                    span { bullet.body }
                                }
                            }
                        }
                    }
                }
                div(.class("fvis")) { visual() }
            }
        }
    }

    func securityGrid() -> HTML {
        section(.class("sec", "sec-dark"), .id("security")) {
            div(.class("wrap")) {
                sectionHead(
                    eyebrow: "Security & privacy", tone: .light,
                    title: headline("Built like it’s ", accent: "your money.", trailing: " Because it is.")
                )
                div(.class("sec-grid")) {
                    for item in FeaturesContent.security {
                        div(.class("sec-tile")) {
                            icon(item.icon)
                            h3 { item.title }
                            p { item.body }
                        }
                    }
                }
            }
        }
    }

    func planCard(_ plan: Plan) -> HTML {
        div(.class("plan", plan.featured ? "hi" : nil)) {
            if plan.featured { span(.class("badge")) { "Most popular" } }
            h3 { plan.name }
            p(.class("pd")) { plan.description }
            p(.class("price")) {
                plan.price
                span { plan.period }
            }
            p(.class("alt")) { plan.alt }
            linkButton(href: plan.ctaHref, variant: plan.featured ? .copper : .line, block: true, "Start free trial")
            ul {
                for feature in plan.features {
                    li {
                        icon(.check)
                        feature
                    }
                }
            }
        }
    }

    func compareTable() -> HTML {
        func mark(_ included: Bool) -> HTML {
            included ? icon(.check) : span(.class("no")) { "–" }
        }
        return div(.class("cmp-wrap")) {
            table(.class("cmp")) {
                thead {
                    tr {
                        th()
                        th { "Penny" }
                        th { "Household" }
                    }
                }
                tbody {
                    for row in PricingContent.compareRows {
                        tr {
                            td { row.feature }
                            td { mark(row.penny) }
                            td { mark(row.household) }
                        }
                    }
                }
            }
        }
    }

    /// The interactive preview: tab list, in-phone tab bar, dots, arrows, keys and swipe all drive one
    /// carousel. Everything renders server-side; `site.js` switches the `on` classes.
    func phonePreview() -> HTML {
        let screens = PreviewContent.screens
        return section(.class("pv"), .data("preview", "")) {
            div(.class("wrap", "pv-grid")) {
                div(.class("pv-tabs"), .role("group"), .aria("label", "Choose a screen")) {
                    for (index, item) in screens.enumerated() {
                        button(
                            .class("pv-tab", index == 0 ? "on" : nil), .aria("pressed", index == 0 ? "true" : "false"),
                            .data("index", String(index))
                        ) {
                            span(.class("n")) { "0\(index + 1)" }
                            span {
                                b { item.title }
                                small { item.description }
                            }
                        }
                    }
                }
                div(.class("pv-stage")) {
                    div(.class("halo"))
                    div(.class("phone", "pv-phone"), .aria("live", "polite")) {
                        div(.class("scr")) {
                            span(.class("island"))
                            statusBar()
                            div(.class("screens")) {
                                for (index, item) in screens.enumerated() {
                                    div(
                                        .class("screen", index == 0 ? "on" : nil), .aria("hidden", index == 0 ? "false" : "true"),
                                        .data("screen", item.screen.rawValue)
                                    ) {
                                        div(.class("ps-body")) { screenBody(item.screen) }
                                        tabBar(active: item.screen, interactive: true)
                                    }
                                }
                            }
                            span(.class("homebar"))
                        }
                    }
                    div(.class("pv-ctl")) {
                        button(.class("arr"), .aria("label", "Previous screen"), .data("step", "-1")) { icon(.chevl) }
                        div(.class("dots")) {
                            for (index, item) in screens.enumerated() {
                                button(
                                    .class("dotb", index == 0 ? "on" : nil), .aria("label", "Show \(item.screen.title) screen"),
                                    .data("index", String(index))
                                )
                            }
                        }
                        button(.class("arr"), .aria("label", "Next screen"), .data("step", "1")) { icon(.chev) }
                    }
                    p(.class("pv-note")) { "Sample data · \(household.name)’s household, \(household.period.month)" }
                }
            }
        }
    }
}
