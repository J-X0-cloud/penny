#if os(iOS)
import PennyCore
import SwiftUI
import UIKit

/// White rounded container used for summary blocks.
struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.paper, in: RoundedRectangle(cornerRadius: Theme.Radius.medium + 2, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium + 2, style: .continuous).strokeBorder(Theme.line2)
            )
    }
}

/// Small capsule button in screen headers.
struct Pill<Label: View>: View {
    let accessibilityLabel: String
    var action: () -> Void = {}
    @ViewBuilder var label: Label

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) { label }
                .font(Typography.sans(13, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Theme.paper, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.line))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ProgressBar: View {
    let fraction: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.line2)
                Capsule().fill(color).frame(width: proxy.size.width * CGFloat(clamped))
            }
        }
        .frame(height: 7)
        .padding(.vertical, 5)
        .accessibilityElement()
        .accessibilityValue("\(Int((clamped * 100).rounded())) percent")
    }

    private var clamped: Double { min(max(fraction, 0), 1) }
}

/// Rounded-square icon tile. Category chips use the category's colours; everything else is violet.
struct Chip: View {
    let icon: IconName
    var foreground: Color = Theme.violet
    var background: Color = Theme.violetLight
    var small = false

    init(icon: IconName, foreground: Color = Theme.violet, background: Color = Theme.violetLight, small: Bool = false) {
        self.icon = icon
        self.foreground = foreground
        self.background = background
        self.small = small
    }

    init(category: Category, small: Bool = false) {
        self.init(icon: category.icon, foreground: Color(category.foreground), background: Color(category.tint), small: small)
    }

    var body: some View {
        PennyIcon(name: icon, color: foreground, size: small ? 15 : 19)
            .frame(width: small ? 28 : 38, height: small ? 28 : 38)
            .background(background, in: RoundedRectangle(cornerRadius: small ? 8 : 11, style: .continuous))
    }
}

struct Avatar: View {
    let member: Member
    var size: CGFloat = 34

    var body: some View {
        Text(member.initial)
            .font(Typography.sans(size * 0.4, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Theme.gradient(for: member.id), in: Circle())
            .accessibilityLabel(member.name)
    }
}

struct CoupleAvatars: View {
    let members: [Member]

    var body: some View {
        HStack(spacing: -8) {
            ForEach(members) { member in
                Avatar(member: member)
                    .overlay(Circle().strokeBorder(Theme.background, lineWidth: member.id == .maya ? 0 : 2))
            }
        }
    }
}

/// Chip, two lines of text and a right-aligned amount: transactions, bills and accounts.
struct ListRow<Title: View>: View {
    let chip: Chip
    @ViewBuilder var title: Title
    var subtitle: String?
    var amount: String?
    var negative = false
    var showsDivider = true

    var body: some View {
        HStack(spacing: 12) {
            chip
            VStack(alignment: .leading, spacing: 1) {
                title
                    .font(Typography.sans(15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(Typography.sans(12.5))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            if let amount {
                Text(amount)
                    .font(Typography.sans(15, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(negative ? Theme.rose : Theme.ink)
            }
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) {
            if showsDivider { Rectangle().fill(Theme.line2).frame(height: 1) }
        }
        .accessibilityElement(children: .combine)
    }
}

struct BillRow: View {
    let bill: Bill
    var showsDivider = true

    var body: some View {
        ListRow(
            chip: Chip(icon: bill.icon),
            title: {
                if let change = bill.priceChange {
                    Text(bill.name) + Text("  +\(change.formatted)").font(Typography.sans(12, weight: .semibold)).foregroundColor(Theme.rose)
                } else {
                    Text(bill.name)
                }
            },
            subtitle: bill.priceChange == nil ? "\(bill.due.label) · \(bill.note)" : bill.due.label,
            amount: bill.amount.formatted,
            showsDivider: showsDivider
        )
    }
}

struct ScreenHeader<Trailing: View>: View {
    let eyebrow: String
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(eyebrow)
                    .font(Typography.sans(13))
                    .foregroundStyle(Theme.muted)
                Text(title)
                    .font(Typography.serif(26, weight: .semibold))
                    .tracking(-0.5)
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer()
            trailing
        }
        .padding(.top, 4)
    }
}

struct SectionTitle: View {
    let title: String
    var badge: Int?
    var actionLabel: String?
    var action: () -> Void = {}

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(Typography.sans(15, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            if let badge {
                Text(String(badge))
                    .font(Typography.sans(11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .frame(minWidth: 20)
                    .background(Theme.copper, in: Capsule())
            }
            Spacer()
            if let actionLabel {
                Button(actionLabel, action: action)
                    .font(Typography.sans(13.5, weight: .medium))
                    .foregroundStyle(Theme.violet)
            }
        }
        .padding(.top, 6)
    }
}

/// Progress ring with content in the middle.
struct Donut<Center: View>: View {
    let fraction: Double
    var size: CGFloat = 108
    var lineWidth: CGFloat = 11
    @ViewBuilder var center: Center

    var body: some View {
        ZStack {
            Circle().stroke(Theme.track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(Theme.violet, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) { center }
        }
        .padding(lineWidth / 2)
        .frame(width: size, height: size)
    }
}

/// Bundled goal and category artwork (`goal-home.webp`, ...), with a soft placeholder if missing.
struct ArtworkImage: View {
    let name: String
    var size: CGFloat = 46
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let image = Self.load(name) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Theme.copperLight
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityHidden(true)
    }

    static func load(_ name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "webp") else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

/// Vertical scrolling page with the app's spacing.
struct ScreenScroll<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) { content }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background)
    }
}
#endif
