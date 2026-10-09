import PennyCore

/// The site's pages, by route.
public enum SitePage: String, CaseIterable, Sendable {
    case home = "/"
    case features = "/features"
    case household = "/household"
    case pricing = "/pricing"
    case app = "/app"

    public var path: String { rawValue }

    public var title: String {
        switch self {
        case .home: SiteContent.defaultTitle
        case .features: "Features | Penny personal finance app"
        case .household: "Household | Shared budgets and goals with Penny"
        case .pricing: "Pricing | Penny personal finance app"
        case .app: "App preview | Penny for iPhone and the web"
        }
    }

    public var description: String {
        switch self {
        case .home:
            SiteContent.defaultDescription
        case .features:
            "Automatic categories, flexible budgets with rollovers, recurring bill tracking, net worth history and bank-grade security. See everything Penny does."
        case .household:
            "Share the accounts you choose with a partner or roommate, split costs fairly, settle up in a tap and save toward shared goals with Penny Household."
        case .pricing:
            "Penny costs $79 a year for one person or $119 a year for a two-person household, with a 14-day free trial, no ads and no data selling."
        case .app:
            "Tap through Penny's iPhone screens, from the daily home view to budgets, recurring bills, net worth and the shared household, plus the web dashboard."
        }
    }
}

extension SiteRenderer {
    /// A full HTML document for `page`.
    public func render(_ page: SitePage) -> String {
        RenderScope.render {
            let content: HTML = switch page {
            case .home: homePage()
            case .features: featuresPage()
            case .household: householdPage()
            case .pricing: pricingPage()
            case .app: appPreviewPage()
            }
            return document(title: page.title, description: page.description, path: page.path, content: content)
        }
    }

    /// The 404 page.
    public func renderNotFound(path: String) -> String {
        RenderScope.render {
            let content = section(.class("phero", "center")) {
                div(.class("wrap")) {
                    eyebrow("404")
                    h1 { headline("Nothing filed ", accent: "under that page.") }
                    p(.class("lede")) { "The page you asked for doesn’t exist. The rest of Penny is right where you left it." }
                    div(.class("btns")) {
                        linkButton(href: "/", "Back to home")
                        linkButton(href: "/app", variant: .line, arrow: true, "Tour the app")
                    }
                }
            }
            return document(title: "Page not found | Penny", description: SiteContent.defaultDescription, path: path, content: content)
        }
    }

    func homePage() -> HTML {
        hero()
            + spendingBento()
            + wealthSection()
            + householdSection()
            + webSection(
                eyebrow: "On the web", title: headline("Big-screen budgeting, ", accent: "same numbers."),
                body: "Everything on your phone is on the web too, with room for the full transaction table, drag-to-edit budgets and bulk recategorizing on a Sunday afternoon."
            )
            + reviews()
            + priceTeaser()
            + ctaBand()
    }

    func featuresPage() -> HTML {
        let intro = section(.class("phero")) {
            div(.class("wrap")) {
                eyebrow("Features")
                h1 { headline("The whole toolkit, ", accent: "none of the homework.") }
                p(.class("lede")) {
                    "Penny does the sorting, adding and remembering so you can spend five minutes a week deciding instead of an evening tallying."
                }
                nav(.class("subnav"), .aria("label", "Feature sections")) {
                    for anchor in FeaturesContent.anchors {
                        a(.href(anchor.href)) { anchor.label }
                    }
                }
            }
        }
        let transactions = featureRow(
            id: "transactions", eyebrow: "Transactions", title: headline("Categorized the moment ", accent: "they post."),
            body: "Penny reads merchant, amount and timing to file each transaction, then learns from the corrections you make. Rules handle the rest: rename a merchant, split a warehouse-club haul across groceries and home, or hide transfers between your own accounts.",
            bullets: FeaturesContent.transactions
        ) { reviewCard() }
        let budgets = featureRow(
            id: "budgets", eyebrow: "Budgets", title: headline("Budgets that bend ", accent: "without breaking."),
            body: "Give each category a monthly number, or let Penny suggest one from your last three months. Unspent money can roll forward, overspending shows up in red while there's still time, and the pace line tells you whether you're on track mid-month.",
            bullets: FeaturesContent.budgets, flip: true
        ) { phone(.budgets, variant: .solo) }
        let recurring = featureRow(
            id: "recurring", eyebrow: "Recurring", title: headline("Every bill, ", accent: "before it’s due."),
            body: "Penny finds recurring charges on its own, puts them on a calendar and tells you when one changes. See the next 30 days of bills in a single number and never be surprised by an annual renewal again.",
            bullets: FeaturesContent.recurring
        ) { phone(.bills, variant: .solo) }
        let netWorth = featureRow(
            id: "networth", eyebrow: "Net worth", title: headline("Your balance sheet, ", accent: "kept current."),
            body: "Link savings, brokerage, retirement and crypto accounts alongside loans and cards. Add manual assets like a car and Penny keeps a monthly history so you can watch the line move the right way.",
            bullets: FeaturesContent.netWorth, flip: true
        ) {
            div(.class("fstack")) {
                netWorthCard()
                allocationCard()
            }
        }
        return intro + transactions + budgets + recurring + netWorth + securityGrid()
            + ctaBand(title: "See your month clearly in five minutes.")
    }

    func householdPage() -> HTML {
        let intro = section(.class("phero", "hh-hero")) {
            div(.class("wrap", "hh-grid")) {
                div {
                    eyebrow("Household")
                    h1 { headline("One view for the two of you. ", accent: "Your own accounts, still yours.") }
                    p(.class("lede")) {
                        "Shared bills, shared goals and a fair split, without merging every account or handing over every receipt."
                    }
                    div(.class("btns")) {
                        linkButton(href: "/pricing", large: true, "Try Household free")
                        linkButton(href: "/app", variant: .line, large: true, arrow: true, "See the screens")
                    }
                }
                div(.class("hh-phones")) {
                    phone(.household, variant: .front)
                    floatCard(className: "f5", image: imageURL("goal-home"), title: "Down payment +$400", note: "Auto-transfer on the 1st")
                    div(.class("float", "f6")) {
                        span(.class("fi")) { icon(.eyeoff) }
                        div {
                            b { "3 accounts private" }
                            small { "Only you can see them" }
                        }
                    }
                }
            }
        }
        let steps = section(.class("sec")) {
            div(.class("wrap")) {
                sectionHead(eyebrow: "How it works", title: headline("Set up in ", accent: "three steps."))
                setupSteps()
            }
        }
        let duo = section(.class("sec", "sec-tint")) {
            div(.class("wrap", "duo")) {
                bentoBox(title: "Shared and private, side by side", body: "Flip an account into the household with one switch. Flip it back any time.") {
                    sharedAccountsCard()
                }
                bentoBox(title: "A running tab, settled in a tap", body: "Penny tallies who paid for what, applies your split and shows one number to settle.") {
                    ledgerCard()
                }
            }
        }
        let goals = section(.class("sec"), .id("goals")) {
            div(.class("wrap")) {
                sectionHead(
                    eyebrow: "Shared goals", title: headline("Save for the ", accent: "big stuff", trailing: " together."),
                    body: "Set a target and a date, and Penny works out the monthly amount, moves it automatically if you like, and shows both of you the progress."
                )
                div(.class("goals")) {
                    for goal in household.goals { goalCard(goal) }
                }
            }
        }
        let faq = section(.class("sec", "sec-tint")) {
            div(.class("wrap", "faq-wrap")) {
                sectionHead(eyebrow: "Questions", tone: .left, title: headline("Sharing, ", accent: "answered."))
                faqList(HouseholdPageContent.faq)
            }
        }
        return intro + steps + duo + goals + faq + ctaBand(
            title: "Run the household like a team.",
            body: "The Household plan covers two people, two logins and every shared goal. Try it free for 14 days."
        )
    }

    func pricingPage() -> HTML {
        let intro = section(.class("phero", "center")) {
            div(.class("wrap")) {
                eyebrow("Pricing")
                h1 { headline("Honest pricing. ", accent: "No ads, ever.") }
                p(.class("lede")) {
                    "Try everything free for 14 days. Then pick the plan that fits how many people are in your money."
                }
            }
        }
        let plans = section(.class("plans-sec")) {
            div(.class("wrap")) {
                div(.class("plans")) {
                    for plan in PricingContent.plans { planCard(plan) }
                }
                p(.class("plans-note")) {
                    icon(.lock)
                    " 14-day free trial on both plans. Cancel any time from Settings."
                }
            }
        }
        let compare = section(.class("sec")) {
            div(.class("wrap")) {
                sectionHead(title: .text("Compare plans"))
                compareTable()
            }
        }
        let email = SiteContent.contactEmail
        let faq = section(.class("sec", "sec-tint"), .id("faq")) {
            div(.class("wrap", "faq-wrap")) {
                sectionHead(
                    eyebrow: "FAQ", tone: .left, title: headline("Good questions, ", accent: "straight answers."),
                    body: p {
                        "Something else? Email "
                        a(.href("mailto:\(email)")) { email }
                        "."
                    }
                )
                faqList(PricingContent.faq)
            }
        }
        return intro + plans + compare + faq + ctaBand()
    }

    func appPreviewPage() -> HTML {
        let intro = section(.class("phero", "center", "pv-hero")) {
            div(.class("wrap")) {
                eyebrow("Interactive preview")
                h1 { headline("Take Penny ", accent: "for a spin.") }
                p(.class("lede")) {
                    "Tap through the real app screens with a sample household’s \(household.period.month). On a phone, swipe the screen left and right."
                }
            }
        }
        let web = webSection(
            eyebrow: "Penny on the web", title: headline("The same household, ", accent: "on a bigger screen."),
            body: "The web app shares one data model with iPhone, so a category fixed on the couch shows up corrected at your desk a second later."
        ) {
            div(.class("plat-row")) {
                for platform in MarketingContent.platforms {
                    div {
                        icon(platform.icon)
                        b { platform.title }
                        span { platform.body }
                    }
                }
            }
        }
        return intro + phonePreview() + web + ctaBand(
            title: "Like what you see?",
            body: "Connect your own accounts and your first month is sorted before the coffee's cold. Free for 14 days."
        )
    }
}
