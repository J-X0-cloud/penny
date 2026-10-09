import Testing
@testable import PennyWeb

@Suite("HTML builder")
struct HTMLBuilderTests {
    @Test func textIsEscaped() {
        let html = div { "<script>alert('x') & \"y\"</script>" }
        #expect(html.rendered == "<div>&lt;script&gt;alert('x') &amp; \"y\"&lt;/script&gt;</div>")
    }

    @Test func attributesAreEscapedAndOrdered() {
        let html = a(.href("/search?q=\"a\"&b=<c>"), .class("x", nil, "", "y")) { "Go" }
        #expect(html.rendered == #"<a href="/search?q=&quot;a&quot;&amp;b=&lt;c&gt;" class="x y">Go</a>"#)
    }

    @Test func emptyClassAndStyleAreOmitted() {
        #expect(span(.class(nil), .style(["width": nil])).rendered == "<span></span>")
        #expect(span(.style(["width": "50%", "background": nil, "color": "red"])).rendered == #"<span style="width:50%;color:red"></span>"#)
    }

    @Test func booleanAttributes() {
        #expect(details(.flag("open")) { "x" }.rendered == "<details open>x</details>")
        #expect(details(.flag("open", false)) { "x" }.rendered == "<details>x</details>")
    }

    @Test func controlFlowInsideBlocks() {
        let items = ["a", "b"]
        let showExtra = false
        let html = ul {
            for item in items {
                li { item }
            }
            if showExtra {
                li { "extra" }
            } else {
                li { "none" }
            }
        }
        #expect(html.rendered == "<ul><li>a</li><li>b</li><li>none</li></ul>")
    }

    @Test func buttonsDefaultToTypeButton() {
        #expect(button(.class("arr")).rendered == #"<button type="button" class="arr"></button>"#)
    }

    @Test func imagesAreLazyWithDimensions() {
        let html = img(src: "/images/goal-home.webp", width: 52, height: 52)
        #expect(html.rendered == #"<img src="/images/goal-home.webp" alt="" width="52" height="52" loading="lazy" decoding="async">"#)
    }

    @Test func renderScopeIDsRestartPerRender() {
        let first = RenderScope.render { [RenderScope.nextID("g"), RenderScope.nextID("g")] }
        let second = RenderScope.render { RenderScope.nextID("g") }
        #expect(first == ["g-1", "g-2"])
        #expect(second == "g-1")
    }
}
