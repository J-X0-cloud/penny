import Foundation
import Hummingbird
import Logging
import PennyCore
import PennyWeb
import PostgresNIO
import ServiceLifecycle

public enum PennyApplication {
    /// Builds the router: site pages, the JSON API, a health check and static files.
    public static func router(api: APIContext, staticDirectory: String) -> Router<BasicRequestContext> {
        let site = SiteRoutes(site: SiteRenderer(household: api.household))
        let router = Router()
        router.addMiddleware {
            LogRequestsMiddleware(.info)
            SecurityHeadersMiddleware()
            NotFoundMiddleware(renderPage: site.notFound)
            FileMiddleware(
                staticDirectory,
                cacheControl: .init([
                    (MediaType(type: .image), [.public, .maxAge(86_400)]),
                    (MediaType(type: .text, subType: "css"), [.public, .maxAge(3_600)]),
                    (MediaType(type: .text, subType: "javascript"), [.public, .maxAge(3_600)]),
                    (MediaType(type: .application, subType: "javascript"), [.public, .maxAge(3_600)]),
                ]),
                searchForIndexHtml: false
            )
        }
        router.get("healthz") { _, _ in
            try Responses.json(["status": "ok"])
        }
        site.register(on: router)
        APIRoutes(context: api).register(on: router)
        return router
    }

    /// The full service: HTTP server plus, when `DATABASE_URL` is set, the Postgres pool.
    public static func make(configuration: ServerConfiguration) throws -> some ApplicationProtocol {
        var logger = Logger(label: "penny")
        logger.logLevel = configuration.logLevel

        let household = Household.sample
        var services: [any Service] = []
        let api: APIContext
        if let databaseURL = configuration.databaseURL {
            let client = PostgresClient(configuration: try DatabaseURL(databaseURL).clientConfiguration, backgroundLogger: logger)
            services.append(client)
            api = APIContext(household: household, ledger: PostgresLedger(client: client, logger: logger), period: { BudgetPeriod.current() })
            logger.info("Serving transactions from Postgres")
        } else {
            api = APIContext(household: household, ledger: InMemoryLedger(transactions: household.transactions), period: { household.period })
            logger.info("DATABASE_URL not set; serving the bundled sample household")
        }

        return Application(
            router: router(api: api, staticDirectory: configuration.staticDirectory),
            configuration: .init(address: .hostname(configuration.host, port: configuration.port), serverName: "penny"),
            services: services,
            logger: logger
        )
    }
}

extension BudgetPeriod {
    /// The calendar month containing `date`, in UTC.
    public static func current(_ date: Date = Date()) -> BudgetPeriod {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let parts = calendar.dateComponents([.month, .day, .weekday], from: date)
        let days = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return BudgetPeriod(
            today: MonthDay(month: parts.month ?? 1, day: parts.day ?? 1),
            weekday: weekdays[((parts.weekday ?? 1) - 1) % 7],
            days: days
        )
    }
}
