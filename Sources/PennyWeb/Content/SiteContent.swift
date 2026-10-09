import PennyCore

/// Copy and navigation for the product site.
public enum SiteContent {
    public static let contactEmail = "hello@pennyapp.com"
    public static let name = "Penny"
    public static let url = "https://pennyapp.com"
    public static let themeColor = "#F7F4EF"
    public static let footerBlurb =
        "Budgets, bills, net worth and a shared household view, on iPhone and the web. Read-only connections, no ads, no selling your data."
    public static let legal = "© 2026 Penny Money Co."
    public static let disclaimer = "Penny is a budgeting tool, not a bank. Account connections are read-only."
    public static let defaultTitle = "Penny | Budgets, bills and net worth in one calm app"
    public static let defaultDescription =
        "Penny is a personal-finance app for iPhone and the web: automatic spending categories, budgets with rollovers, recurring bills, net worth and a shared household view."

    public static let nav: [NavLink] = [
        NavLink(href: "/features", label: "Features"),
        NavLink(href: "/household", label: "Household"),
        NavLink(href: "/pricing", label: "Pricing"),
        NavLink(href: "/app", label: "App preview"),
    ]

    public static let footerColumns: [(title: String, links: [NavLink])] = [
        ("Product", nav),
        ("Learn", [
            NavLink(href: "/features#budgets", label: "Budgets & rollovers"),
            NavLink(href: "/features#recurring", label: "Recurring bills"),
            NavLink(href: "/features#networth", label: "Net worth"),
            NavLink(href: "/features#security", label: "Security"),
        ]),
        ("Company", [
            NavLink(href: "/pricing#faq", label: "FAQ"),
            NavLink(href: "mailto:\(contactEmail)", label: "Contact"),
            NavLink(href: "#", label: "Privacy"),
            NavLink(href: "#", label: "Terms"),
        ]),
    ]
}

public enum MarketingContent {
    public static let trustPoints: [IconLabel] = [
        IconLabel(icon: .lock, label: "Read-only bank connections"),
        IconLabel(icon: .face, label: "Face ID lock on every open"),
        IconLabel(icon: .ban, label: "No ads. No selling your data."),
        IconLabel(icon: .download, label: "Export to CSV anytime"),
    ]

    public static let heroFloats: [FloatCard] = [
        FloatCard(className: "f1", image: "goal-home", title: "Down payment", note: "$38,400 saved"),
        FloatCard(className: "f2", image: "goal-trip", title: "Yosemite in May", note: "64% there"),
        FloatCard(className: "f3", image: "cat-groceries", title: "Groceries", note: "$101.80 left"),
        FloatCard(className: "f4", image: "goal-date", title: "Date night", note: "Rolled over $42"),
    ]

    public static let householdTicks: [IconLabel] = [
        IconLabel(icon: .eyeoff, label: "Private accounts stay private, always"),
        IconLabel(icon: .split, label: "Fair splits: 50/50, by income, or custom"),
        IconLabel(icon: .target, label: "Shared goals with automatic transfers"),
    ]

    public static let testimonials: [Testimonial] = [
        Testimonial(
            quote: "I used to reconcile our spending in a spreadsheet every Sunday night. Now I clear the review queue with my coffee and I’m done in two minutes.",
            name: "Dana R.", location: "Portland, OR"
        ),
        Testimonial(
            quote: "The household view ended the “did you pay the electric?” texts. We each keep our own cards private and share the bills that are actually shared.",
            name: "Marcus T.", location: "Austin, TX"
        ),
        Testimonial(
            quote: "Rollovers are the feature I didn’t know I needed. Leftover fun money quietly builds toward a trip instead of disappearing.",
            name: "Priya S.", location: "Oakland, CA"
        ),
    ]

    public static let platforms: [Feature] = [
        Feature(icon: .phone, title: "iPhone", body: "iOS 17 and later · widgets for spending and bills"),
        Feature(icon: .monitor, title: "Web", body: "Any modern browser · built for budgeting sessions"),
        Feature(icon: .users, title: "Household", body: "Two logins, one shared view"),
    ]
}

public enum FeaturesContent {
    public static let anchors: [NavLink] = [
        NavLink(href: "#transactions", label: "Transactions"),
        NavLink(href: "#budgets", label: "Budgets"),
        NavLink(href: "#recurring", label: "Recurring"),
        NavLink(href: "#networth", label: "Net worth"),
        NavLink(href: "#security", label: "Security"),
    ]

    public static let transactions: [Feature] = [
        Feature(icon: .sparkle, title: "Smart categories", body: "Suggestions get sharper with every fix."),
        Feature(icon: .tag, title: "Rules & renames", body: "Clean up cryptic merchant names for good."),
        Feature(icon: .split, title: "Split a purchase", body: "One receipt, several categories."),
    ]

    public static let budgets: [Feature] = [
        Feature(icon: .pie, title: "Category budgets", body: "Monthly limits with a live progress ring."),
        Feature(icon: .repeat, title: "Rollovers", body: "Leftover money carries into next month."),
        Feature(icon: .bell, title: "Pace alerts", body: "A nudge when a category runs hot."),
    ]

    public static let recurring: [Feature] = [
        Feature(icon: .calendar, title: "Bill calendar", body: "What’s due, when, and from which account."),
        Feature(icon: .trend, title: "Price-change flags", body: "Know the moment a subscription goes up."),
        Feature(icon: .inbox, title: "Forgotten subscriptions", body: "Spot the ones you stopped using."),
    ]

    public static let netWorth: [Feature] = [
        Feature(icon: .trend, title: "Twelve-month history", body: "Monthly snapshots, automatically."),
        Feature(icon: .pie, title: "Allocation", body: "See how diversified you really are."),
        Feature(icon: .wallet, title: "Manual assets", body: "Cars, collectibles, money owed to you."),
    ]

    public static let security: [Feature] = [
        Feature(
            icon: .lock, title: "Read-only by design",
            body: "Penny connects through a regulated data aggregator with read-only access. Nobody, including us, can move money from your accounts."
        ),
        Feature(
            icon: .shieldck, title: "Encrypted in transit and at rest",
            body: "Every connection uses TLS and stored data is encrypted. Your bank login is never stored on Penny’s servers."
        ),
        Feature(icon: .face, title: "Face ID and passcode", body: "Lock the app on every open, and hide balances from the home screen with one tap."),
        Feature(icon: .ban, title: "No ads, no data sales", body: "We charge a subscription so we never have to sell your spending habits to anyone."),
    ]
}

public enum HouseholdPageContent {
    public static let setupSteps: [Feature] = [
        Feature(icon: .mail, title: "Invite", body: "Send an invite from Settings. Your partner signs in on their own phone with their own login."),
        Feature(icon: .eye, title: "Choose what to share", body: "Pick which accounts join the household. Everything else stays visible to its owner only."),
        Feature(icon: .split, title: "Set the split", body: "Even, by income, or custom per category. Penny keeps a running settle-up balance."),
    ]

    public static let faq: [FaqItem] = [
        FaqItem(
            question: "Can my partner see my personal accounts?",
            answer: "No. Only accounts you mark as shared appear in the household view. Private accounts, their balances and their transactions stay visible to you alone."
        ),
        FaqItem(question: "Do we both need to pay?", answer: "No. The Household plan covers two people with separate logins on one subscription."),
        FaqItem(
            question: "What if we split some things differently?",
            answer: "Set a default split and override it per category or per transaction. Rent can be by income while groceries stay 50/50."
        ),
        FaqItem(
            question: "Can roommates use it?",
            answer: "Yes. Household works for any two people sharing costs, whether that’s a partner, a roommate or a family member."
        ),
    ]
}

public enum PricingContent {
    public static let plans: [Plan] = [
        Plan(
            id: "penny", name: "Penny", description: "For one person and all their accounts.", price: "$79", period: "/year",
            alt: "That’s $6.58 a month, or $8.99 billed monthly",
            features: ["Unlimited accounts", "Budgets, rollovers & rules", "Recurring bills & alerts", "Net worth & investments", "iPhone and web"],
            ctaHref: "mailto:\(SiteContent.contactEmail)?subject=Penny%20trial", featured: false
        ),
        Plan(
            id: "household", name: "Household", description: "For two people sharing a home and some of their money.",
            price: "$119", period: "/year", alt: "That’s $9.92 a month, or $12.99 billed monthly",
            features: ["Everything in Penny", "Two separate logins", "Shared & private accounts", "Split tracking & settle up", "Shared goals"],
            ctaHref: "mailto:\(SiteContent.contactEmail)?subject=Penny%20Household%20trial", featured: true
        ),
    ]

    public static let teasers: [PriceTeaser] = [
        PriceTeaser(name: "Penny", monthly: "$6.58", note: "$79 billed yearly · 1 person", highlight: false),
        PriceTeaser(name: "Household", monthly: "$9.92", note: "$119 billed yearly · 2 people", highlight: true),
    ]

    public static let compareRows: [CompareRow] = [
        CompareRow(feature: "Automatic categories & rules", penny: true, household: true),
        CompareRow(feature: "Budgets with rollovers", penny: true, household: true),
        CompareRow(feature: "Recurring bills & price alerts", penny: true, household: true),
        CompareRow(feature: "Net worth & investments", penny: true, household: true),
        CompareRow(feature: "iPhone and web apps", penny: true, household: true),
        CompareRow(feature: "CSV export", penny: true, household: true),
        CompareRow(feature: "Second login", penny: false, household: true),
        CompareRow(feature: "Shared accounts & split tracking", penny: false, household: true),
        CompareRow(feature: "Shared goals", penny: false, household: true),
    ]

    public static let faq: [FaqItem] = [
        FaqItem(
            question: "How does the free trial work?",
            answer: "Every new account gets 14 days of the full product. You can explore sample data before connecting anything, and nothing is charged until the trial ends."
        ),
        FaqItem(
            question: "Which banks does Penny support?",
            answer: "Most US banks, credit unions, credit cards, brokerages and retirement providers. You can also add manual accounts for anything we can’t connect."
        ),
        FaqItem(
            question: "Can Penny move my money?",
            answer: "No. Connections are read-only. Penny can see balances and transactions but cannot make transfers or payments."
        ),
        FaqItem(
            question: "Why isn’t Penny free?",
            answer: "Free finance apps are usually paid for by ads or by selling insights about your spending. Charging a fair subscription keeps our incentives lined up with yours."
        ),
        FaqItem(
            question: "Can I switch plans or cancel?",
            answer: "Yes. Upgrade to Household, downgrade or cancel from Settings at any time. Yearly plans are refunded pro rata within the first 30 days."
        ),
        FaqItem(question: "Can I take my data with me?", answer: "Always. Export every transaction, budget and balance history to CSV from the web app."),
    ]
}

public enum PreviewContent {
    public static let screens: [PreviewScreen] = [
        PreviewScreen(
            screen: .home, title: "Today at a glance",
            description: "One calm screen each morning: what you’ve spent against your budget, whether you’re on pace, what’s due next and what Penny needs you to look at."
        ),
        PreviewScreen(
            screen: .budgets, title: "Budgets that bend",
            description: "Set a number per category, watch the ring fill, and let unspent money roll into next month instead of vanishing. Overspending shows up early, in red, while there’s still time to adjust."
        ),
        PreviewScreen(
            screen: .bills, title: "Every bill, before it’s due",
            description: "Penny spots recurring charges on its own, lays them out on a calendar and flags the ones that quietly got more expensive."
        ),
        PreviewScreen(
            screen: .netWorth, title: "Your whole balance sheet",
            description: "Checking, savings, brokerage, retirement, crypto, the car and the loans against them, rolled into one number with a year of history."
        ),
        PreviewScreen(
            screen: .household, title: "Shared, not merged",
            description: "Invite a partner, choose which accounts you share, see who paid for what and save toward the goals you’re chasing together."
        ),
    ]
}
