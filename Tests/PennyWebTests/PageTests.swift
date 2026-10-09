import Foundation
import PennyCore
import Testing
@testable import PennyWeb

@Suite("Site pages")
struct PageTests {
    let site = SiteRenderer()

    @Test(arguments: SitePage.allCases)
    func everyPageIsAWellFormedDocument(page: SitePage) throws {
        let html = site.render(page)
        #expect(html.hasPrefix("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\">"))
        #expect(html.contains("<title>\(Escape.text(page.title))</title>"))
        #expect(html.contains(#"<link rel="stylesheet" href="/css/site.css">"#))
        #expect(html.contains(#"<main id="main">"#))
        try TagBalance.check(html)
    }

    @Test(arguments: SitePage.allCases)
    func gradientIDsAreUniqueAndResolve(page: SitePage) {
        let html = site.render(page)
        let ids = matches(of: #"<linearGradient id="([^"]+)""#, in: html)
        #expect(Set(ids).count == ids.count, "duplicate gradient ids on \(page.path)")
        for reference in matches(of: #"url\(#([^)]+)\)"#, in: html) {
            #expect(ids.contains(reference), "\(reference) is not defined on \(page.path)")
        }
    }

    @Test func renderingIsDeterministic() {
        #expect(site.render(.home) == site.render(.home))
    }

    @Test func homeShowsTheHouseholdNumbers() {
        let html = site.render(.home)
        // Hero phone: spent, budget and pace.
        #expect(html.contains("$1,708<span>.42</span>"))
        #expect(html.contains("of $2,250 budget · <b>$92 under pace</b>"))
        // Budgets phone and dashboard.
        #expect(html.contains("<b>$542</b><small>left</small>"))
        #expect(html.contains(#"<em class="ov">$13 over</em>"#))
        // Net worth card and household phone.
        #expect(html.contains(#"<p class="nw-n">$140,826</p>"#))
        #expect(html.contains("$17,850 over 12 months"))
        #expect(html.contains("Jordan owes you $109.00"))
        // Cash flow and recurring.
        #expect(html.contains("$3,870 <small>saved in September · 39% of income</small>"))
        #expect(html.contains(#"Streaming <em class="up">+$2.00</em>"#))
        // Dashboard KPIs.
        #expect(html.contains("2.9% vs Aug"))
        #expect(html.contains("6 days left"))
        #expect(html.contains("$2,572.40 over the next 30 days"))
        #expect(html.contains("<td class=\"r\">-$57.81</td>"))
    }

    @Test func navigationMarksTheCurrentPage() {
        let html = site.render(.pricing)
        #expect(html.contains(#"<a href="/pricing" aria-current="page">Pricing</a>"#))
        #expect(!html.contains(#"<a href="/features" aria-current="page">"#))
    }

    @Test func previewRendersEveryScreenWithOneActive() {
        let html = site.render(.app)
        #expect(matches(of: #"<div class="screen( on)?" aria-hidden="(?:true|false)" data-screen="(\w+)""#, in: html).count == 5)
        #expect(html.components(separatedBy: #"class="screen on""#).count == 2)
        #expect(html.components(separatedBy: #"<button type="button" class="pv-tab"#).count == 6)
        #expect(html.contains(#"data-step="-1""#))
        #expect(html.contains("Sample data · Maya &amp; Jordan’s household, September"))
    }

    @Test func billsScreenUsesTheComputedWeek() {
        let html = site.render(.features)
        #expect(html.contains("<p>October</p>"))
        #expect(html.contains(#"<span class="on"><small>W</small><b>1</b><i></i></span>"#))
        #expect(html.contains("<span><small>T</small><b>2</b></span>"))
        #expect(html.contains("Streaming went up $2.00"))
    }

    @Test func householdPageHasSwitchesAndLedger() {
        let html = site.render(.household)
        #expect(html.contains(#"role="switch" aria-checked="true" aria-label="Share Joint checking" class="tog on""#))
        #expect(html.contains(#"data-private-label="Only Jordan">Only Jordan</span>"#))
        #expect(html.contains("Jordan owes $41.93") == false)
        #expect(html.contains("Jordan owes $109.00"))
        #expect(html.contains("Paid by Maya · split 50/50"))
        #expect(html.components(separatedBy: #"<details class="faq""#).count == 5)
        #expect(html.contains(#"<details class="faq" open>"#))
    }

    @Test func pricingPageListsPlansAndComparison() {
        let html = site.render(.pricing)
        #expect(html.contains(#"<div class="plan hi"><span class="badge">Most popular</span><h3>Household</h3>"#))
        #expect(html.contains("mailto:hello@pennyapp.com?subject=Penny%20Household%20trial"))
        #expect(html.components(separatedBy: "<tr>").count == 11)
        #expect(html.contains(#"<span class="no">–</span>"#))
    }

    @Test func notFoundPage() throws {
        let html = site.renderNotFound(path: "/missing")
        #expect(html.contains("Nothing filed <em>under that page.</em>"))
        try TagBalance.check(html)
    }

    @Test func iconsRenderEveryShape() {
        let html = RenderScope.render { site.icon(.ticket).rendered + site.icon(.paw).rendered + site.icon(.grid).rendered }
        #expect(html.contains(#"stroke-dasharray="1.5 2.2""#))
        #expect(html.contains(#"<circle cx="6.5" cy="10.5" r="1.7"></circle>"#))
        #expect(html.contains(#"<rect x="4" y="4" width="7" height="7" rx="1.8"></rect>"#))
    }

    @Test func customHouseholdFlowsThrough() {
        var household = Household.sample
        household.sharedSpend = [.maya: 100, .jordan: 300]
        let html = SiteRenderer(household: household).render(.home)
        #expect(html.contains("Jordan owes you $0.00"))
    }

    private func matches(of pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            let group = match.numberOfRanges > 1 ? match.range(at: match.numberOfRanges - 1) : match.range
            return Range(group, in: text).map { String(text[$0]) }
        }
    }
}

/// Checks that every opened element is closed in order, which catches builder mistakes that a
/// browser would silently repair.
enum TagBalance {
    struct Mismatch: Error, CustomStringConvertible {
        let description: String
    }

    static let voidElements: Set<String> = ["meta", "link", "img", "br", "hr", "input"]

    static func check(_ html: String) throws {
        let regex = try NSRegularExpression(pattern: #"<(/?)([a-zA-Z][a-zA-Z0-9]*)[^>]*>"#)
        var stack: [String] = []
        for match in regex.matches(in: html, range: NSRange(html.startIndex..., in: html)) {
            guard let closingRange = Range(match.range(at: 1), in: html),
                  let nameRange = Range(match.range(at: 2), in: html) else { continue }
            let name = html[nameRange].lowercased()
            if voidElements.contains(name) { continue }
            if html[closingRange].isEmpty {
                stack.append(name)
            } else {
                guard stack.last == name else {
                    throw Mismatch(description: "</\(name)> closes <\(stack.last ?? "nothing")>")
                }
                stack.removeLast()
            }
        }
        guard stack.isEmpty else { throw Mismatch(description: "unclosed: \(stack.joined(separator: ", "))") }
    }
}
