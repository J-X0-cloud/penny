import PennyCore

public struct NavLink: Hashable, Sendable {
    public let href: String
    public let label: String
}

public struct IconLabel: Hashable, Sendable {
    public let icon: IconName
    public let label: String
}

public struct Feature: Hashable, Sendable {
    public let icon: IconName
    public let title: String
    public let body: String
}

public struct Testimonial: Hashable, Sendable {
    public let quote: String
    public let name: String
    public let location: String
}

public struct FaqItem: Hashable, Sendable {
    public let question: String
    public let answer: String
}

public struct Plan: Hashable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let price: String
    public let period: String
    public let alt: String
    public let features: [String]
    public let ctaHref: String
    public let featured: Bool
}

public struct PriceTeaser: Hashable, Sendable {
    public let name: String
    public let monthly: String
    public let note: String
    public let highlight: Bool
}

public struct CompareRow: Hashable, Sendable {
    public let feature: String
    public let penny: Bool
    public let household: Bool
}

/// A floating goal/category card around the hero phones.
public struct FloatCard: Hashable, Sendable {
    public let className: String
    public let image: String
    public let title: String
    public let note: String
}

/// A screen in the interactive preview: the tab plus the copy beside it.
public struct PreviewScreen: Hashable, Sendable {
    public let screen: AppScreen
    public let title: String
    public let description: String
}
