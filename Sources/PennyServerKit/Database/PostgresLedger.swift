import Foundation
import Logging
import PennyCore
import PostgresNIO

/// Ledger backed by the `transactions` table.
public struct PostgresLedger: LedgerRepository {
    private let client: PostgresClient
    private let logger: Logger

    public init(client: PostgresClient, logger: Logger) {
        self.client = client
        self.logger = logger
    }

    private typealias Row = (String, String, String, Int64, Date, String, String?, Bool)

    public func transactions(matching query: TransactionQuery) async throws -> [Transaction] {
        let limit = query.limit
        let rows: PostgresRowSequence
        if let category = query.category?.rawValue {
            rows = try await client.query(
                """
                SELECT t.id, t.merchant, t.category_key, t.amount_cents, t.posted_at, a.name, m.initial, t.reviewed
                FROM transactions t
                JOIN accounts a ON a.id = t.account_id
                LEFT JOIN members m ON m.id = t.paid_by_id
                WHERE t.hidden = false AND t.category_key = \(category)
                ORDER BY t.posted_at DESC, t.id
                LIMIT \(limit)
                """,
                logger: logger
            )
        } else {
            rows = try await client.query(
                """
                SELECT t.id, t.merchant, t.category_key, t.amount_cents, t.posted_at, a.name, m.initial, t.reviewed
                FROM transactions t
                JOIN accounts a ON a.id = t.account_id
                LEFT JOIN members m ON m.id = t.paid_by_id
                WHERE t.hidden = false
                ORDER BY t.posted_at DESC, t.id
                LIMIT \(limit)
                """,
                logger: logger
            )
        }
        var transactions: [Transaction] = []
        for try await row in rows.decode(Row.self) {
            if let transaction = Self.transaction(from: row) {
                transactions.append(transaction)
            }
        }
        return transactions
    }

    public func recategorize(transactionID: String, to category: CategoryKey) async throws -> Transaction? {
        let rows = try await client.query(
            """
            WITH updated AS (
                UPDATE transactions SET category_key = \(category.rawValue), reviewed = true
                WHERE id = \(transactionID)
                RETURNING id, merchant, category_key, amount_cents, posted_at, account_id, paid_by_id, reviewed
            )
            SELECT u.id, u.merchant, u.category_key, u.amount_cents, u.posted_at, a.name, m.initial, u.reviewed
            FROM updated u
            JOIN accounts a ON a.id = u.account_id
            LEFT JOIN members m ON m.id = u.paid_by_id
            """,
            logger: logger
        )
        for try await row in rows.decode(Row.self) {
            return Self.transaction(from: row)
        }
        return nil
    }

    private static func transaction(from row: Row) -> Transaction? {
        let (id, merchant, categoryKey, amountCents, postedAt, account, initial, reviewed) = row
        guard let category = CategoryKey(rawValue: categoryKey) else { return nil }
        return Transaction(
            id: id, merchant: merchant, category: category, amount: Money(cents: Int(amountCents)),
            postedOn: monthDay(postedAt), account: account, paidBy: initial == MemberID.jordan.initial ? .jordan : .maya,
            reviewed: reviewed
        )
    }

    static func monthDay(_ date: Date) -> MonthDay {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.month, .day], from: date)
        return MonthDay(month: components.month ?? 1, day: components.day ?? 1)
    }
}
