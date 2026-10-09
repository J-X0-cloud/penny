import PennyCore

/// The site chrome: document head, header with the mobile menu, and footer.
extension SiteRenderer {
    func siteHeader(currentPath: String) -> HTML {
        func links() -> HTML {
            HTML.joined(SiteContent.nav.map { item in
                a(.href(item.href), currentPath.hasPrefix(item.href) ? .aria("current", "page") : .class()) { item.label }
            })
        }
        return header(.class("site-head")) {
            div(.class("wrap", "head-row")) {
                wordmark()
                nav(.class("nav"), .aria("label", "Main")) { links() }
                div(.class("head-cta")) {
                    a(.class("login"), .href("/app")) { "Log in" }
                    a(.class("btn", "btn-primary"), .href("/pricing")) { "Start free trial" }
                }
                details(.class("mnav")) {
                    summary(.aria("label", "Open menu")) {
                        span()
                        span()
                        span()
                    }
                    div(.class("mnav-panel")) {
                        links()
                        a(.class("btn", "btn-primary"), .href("/pricing")) { "Start free trial" }
                    }
                }
            }
        }
    }

    func siteFooter() -> HTML {
        footer(.class("site-foot")) {
            div(.class("wrap")) {
                div(.class("foot-grid")) {
                    div(.class("foot-brand")) {
                        wordmark(.light)
                        p { SiteContent.footerBlurb }
                        div(.class("plat")) {
                            span {
                                icon(.phone)
                                " iPhone"
                            }
                            span {
                                icon(.monitor)
                                " Web"
                            }
                        }
                    }
                    for column in SiteContent.footerColumns {
                        div {
                            h4 { column.title }
                            for link in column.links {
                                a(.href(link.href)) { link.label }
                            }
                        }
                    }
                }
                div(.class("foot-base")) {
                    span { SiteContent.legal }
                    span { SiteContent.disclaimer }
                }
            }
        }
    }

    /// A complete HTML document around `content`.
    func document(title: String, description: String, path: String, content: HTML) -> String {
        let head = HTML.raw("<meta charset=\"utf-8\">")
            + voidElement("meta", [Attribute("name", "viewport"), Attribute("content", "width=device-width, initial-scale=1")])
            + element("title", []) { title }
            + voidElement("meta", [Attribute("name", "description"), Attribute("content", description)])
            + voidElement("meta", [Attribute("name", "theme-color"), Attribute("content", SiteContent.themeColor)])
            + voidElement("meta", [Attribute("property", "og:type"), Attribute("content", "website")])
            + voidElement("meta", [Attribute("property", "og:site_name"), Attribute("content", SiteContent.name)])
            + voidElement("meta", [Attribute("property", "og:title"), Attribute("content", title)])
            + voidElement("meta", [Attribute("property", "og:description"), Attribute("content", description)])
            + voidElement("link", [Attribute("rel", "canonical"), .href(SiteContent.url + (path == "/" ? "" : path))])
            + voidElement("link", [Attribute("rel", "icon"), .href("/icon.svg"), .type("image/svg+xml")])
            + voidElement("link", [Attribute("rel", "preconnect"), .href("https://fonts.googleapis.com")])
            + voidElement("link", [Attribute("rel", "preconnect"), .href("https://fonts.gstatic.com"), Attribute("crossorigin", nil)])
            + voidElement("link", [
                Attribute("rel", "stylesheet"),
                .href("https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400..700;1,9..144,400..700&family=Inter:wght@400;500;600;700&display=swap"),
            ])
            + voidElement("link", [Attribute("rel", "stylesheet"), .href("/css/site.css")])
            + element("script", [.src("/js/site.js"), Attribute("defer", nil)]) { HTML.empty }

        let body = element("body", []) {
            a(.class("skip"), .href("#main")) { "Skip to content" }
            siteHeader(currentPath: path)
            element("main", [.id("main")]) { content }
            siteFooter()
        }
        return "<!DOCTYPE html>" + (element("html", [Attribute("lang", "en")]) {
            element("head", []) { head }
            body
        }).rendered
    }
}
