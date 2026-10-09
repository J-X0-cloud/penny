/// Filters for listing transactions.
public struct TransactionQuery: Hashable, Sendable {
    public static let defaultLimit = 50
    public static let limitRange = 1...200

    public var category: CategoryKey?
    public var limit: Int

    public init(category: CategoryKey? = nil, limit: Int = TransactionQuery.defaultLimit) {
        self.category = category
        self.limit = limit
    }

    /// Builds a query from raw URL parameters, collecting every problem rather than stopping at the
    /// first. Empty parameters count as absent.
    public init(category rawCategory: String?, limit rawLimit: String?) throws(ValidationError) {
        var errors = ValidationError()
        var category: CategoryKey?
        var limit = TransactionQuery.defaultLimit

        if let rawCategory, !rawCategory.isEmpty {
            if let key = CategoryKey(rawValue: rawCategory) {
                category = key
            } else {
                let options = CategoryKey.allCases.map { "'\($0.rawValue)'" }.joined(separator: " | ")
                errors.add("category", "Invalid enum value. Expected \(options), received '\(rawCategory)'")
            }
        }
        if let rawLimit, !rawLimit.isEmpty {
            if let value = Int(rawLimit.trimmingWhitespace) {
                if value < TransactionQuery.limitRange.lowerBound {
                    errors.add("limit", "Number must be greater than or equal to \(TransactionQuery.limitRange.lowerBound)")
                } else if value > TransactionQuery.limitRange.upperBound {
                    errors.add("limit", "Number must be less than or equal to \(TransactionQuery.limitRange.upperBound)")
                } else {
                    limit = value
                }
            } else if Double(rawLimit.trimmingWhitespace) != nil {
                errors.add("limit", "Expected integer, received float")
            } else {
                errors.add("limit", "Expected number, received nan")
            }
        }
        guard errors.isEmpty else { throw errors }
        self.init(category: category, limit: limit)
    }

    public func matches(_ transaction: Transaction) -> Bool {
        category == nil || transaction.category == category
    }
}

/// Where transactions live. The API serves from Postgres when `DATABASE_URL` is set and from the
/// in-memory sample ledger otherwise; the iPhone app uses the in-memory ledger for previews.
public protocol LedgerRepository: Sendable {
    /// Visible transactions, newest first.
    func transactions(matching query: TransactionQuery) async throws -> [Transaction]
    /// Moves a transaction to another category and marks it reviewed. Returns `nil` if no
    /// transaction has that id.
    func recategorize(transactionID: String, to category: CategoryKey) async throws -> Transaction?
}

/// Ledger backed by an in-memory copy of a household's transactions.
public actor InMemoryLedger: LedgerRepository {
    private var rows: [Transaction]

    public init(transactions: [Transaction] = Household.sample.transactions) {
        self.rows = transactions
    }

    public func transactions(matching query: TransactionQuery) -> [Transaction] {
        Array(rows.filter(query.matches).prefix(query.limit))
    }

    public func recategorize(transactionID: String, to category: CategoryKey) -> Transaction? {
        guard let index = rows.firstIndex(where: { $0.id == transactionID }) else { return nil }
        rows[index].category = category
        rows[index].reviewed = true
        return rows[index]
    }
}

extension String {
    var trimmingWhitespace: String {
        var scalars = Substring(self)
        while let first = scalars.first, first.isWhitespace { scalars.removeFirst() }
        while let last = scalars.last, last.isWhitespace { scalars.removeLast() }
        return String(scalars)
    }
}
