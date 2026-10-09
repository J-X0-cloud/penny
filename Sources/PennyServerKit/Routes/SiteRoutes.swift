import HTTPTypes
import Hummingbird
import PennyCore
import PennyWeb

/// The product site. Pages only depend on the household, so each one is rendered once at startup
/// and served from memory.
struct SiteRoutes: Sendable {
    let pages: [String: String]
    let notFound: @Sendable (String) -> String

    init(site: SiteRenderer) {
        var pages: [String: String] = [:]
        for page in SitePage.allCases {
            pages[page.path] = site.render(page)
        }
        self.pages = pages
        self.notFound = { path in site.renderNotFound(path: path) }
    }

    func register(on router: Router<some RequestContext>) {
        for page in SitePage.allCases {
            guard let document = pages[page.path] else { continue }
            router.get(RouterPath(page.path)) { _, _ in Responses.html(document) }
            router.head(RouterPath(page.path)) { _, _ in Responses.html(document) }
        }
    }
}

/// Turns unmatched routes into the HTML 404 page for browsers and a JSON error under `/api`.
struct NotFoundMiddleware<Context: RequestContext>: RouterMiddleware {
    let renderPage: @Sendable (String) -> String

    func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        do {
            return try await next(request, context)
        } catch let error as HTTPError where error.status == .notFound {
            let path = request.uri.path
            if path == "/api" || path.hasPrefix("/api/") {
                return try Responses.error("Not found", status: .notFound)
            }
            var response = Responses.html(renderPage(path), status: .notFound)
            response.headers[.cacheControl] = "no-store"
            return response
        }
    }
}

/// Conservative security headers on every response.
struct SecurityHeadersMiddleware<Context: RequestContext>: RouterMiddleware {
    func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        var response = try await next(request, context)
        response.headers[.xContentTypeOptions] = "nosniff"
        response.headers[.referrerPolicy] = "strict-origin-when-cross-origin"
        response.headers[.xFrameOptions] = "SAMEORIGIN"
        return response
    }
}

extension HTTPField.Name {
    static let referrerPolicy = Self("Referrer-Policy")!
    static let xFrameOptions = Self("X-Frame-Options")!
}
