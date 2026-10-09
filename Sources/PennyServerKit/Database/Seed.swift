import Foundation
import Logging
import PennyCore
import PostgresNIO

/// Loads a household into an empty database so the API has something to serve. Existing rows are
/// left alone (`ON CONFLICT DO NOTHING`), so seeding twice is harmless.
public enum Seed {
    public static func load(
        _ household: Household, into client: PostgresClient, year: Int, logger: Logger
    ) async throws {
        let householdID = "sample"
        try await client.withTransaction(logger: logger) { db in
            try await db.query(
                "INSERT INTO households (id, name) VALUES (\(householdID), \(household.name)) ON CONFLICT DO NOTHING",
                logger: logger
            )
            for member in household.members {
                let id = memberRowID(member.id)
                let email = "\(member.name.lowercased())@sample.pennyapp.com"
                let income = member.monthlyIncome.map { Int64($0.cents) }
                try await db.query(
                    """
                    INSERT INTO members (id, household_id, name, email, initial, monthly_income_cents)
                    VALUES (\(id), \(householdID), \(member.name), \(email), \(member.initial), \(income))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
            for category in household.categories {
                try await db.query(
                    """
                    INSERT INTO categories (key, label, icon, fg, bg)
                    VALUES (\(category.key.rawValue), \(category.label), \(category.icon.rawValue), \(category.foreground.css), \(category.tint.css))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
                let budgetID = "\(householdID)-\(category.key.rawValue)-\(year)-\(household.period.today.month)"
                let month = date(year: year, month: household.period.today.month, day: 1)
                try await db.query(
                    """
                    INSERT INTO budgets (id, household_id, category_key, month, limit_cents, rollover_cents)
                    VALUES (\(budgetID), \(householdID), \(category.key.rawValue), \(month), \(Int64(category.budget.cents)), \(Int64(category.rollover.cents)))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
            let sharedByName = Dictionary(household.sharedAccounts.map { ($0.name, $0) }, uniquingKeysWith: { first, _ in first })
            for account in household.accounts {
                let shared = sharedByName[account.name]?.shared ?? false
                try await db.query(
                    """
                    INSERT INTO accounts (id, household_id, account_group, name, institution, balance_cents, shared, manual)
                    VALUES (\(account.id), \(householdID), \(account.group.databaseValue), \(account.name), \(account.institution), \(Int64(account.balance.cents)), \(shared), \(account.institution == "Manual estimate"))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
            // Personal accounts that only appear in the household's sharing settings (e.g. a
            // member's debit card) still need a row for their transactions to point at.
            for account in household.sharedAccounts where !household.accounts.contains(where: { $0.name == account.name }) {
                let owner: String? = switch account.owner {
                case .both: nil
                case let .member(id): memberRowID(id)
                }
                let group = account.icon == .trend ? AccountGroup.investments : .cash
                try await db.query(
                    """
                    INSERT INTO accounts (id, household_id, owner_id, account_group, name, institution, balance_cents, shared)
                    VALUES (\(account.id), \(householdID), \(owner), \(group.databaseValue), \(account.name), \(account.institution), \(Int64(0)), \(account.shared))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
            for transaction in household.transactions {
                let accountID = accountRowID(forTransactionAccount: transaction.account, in: household)
                let postedAt = date(year: year, month: transaction.postedOn.month, day: transaction.postedOn.day, hour: 12)
                try await db.query(
                    """
                    INSERT INTO transactions (id, account_id, paid_by_id, category_key, merchant, amount_cents, posted_at)
                    VALUES (\(transaction.id), \(accountID), \(memberRowID(transaction.paidBy)), \(transaction.category.rawValue), \(transaction.merchant), \(Int64(transaction.amount.cents)), \(postedAt))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
            for bill in household.bills {
                let previous = bill.priceChange.map { Int64((bill.amount - $0).cents) }
                let due = date(year: year, month: bill.due.month, day: bill.due.day)
                try await db.query(
                    """
                    INSERT INTO bills (id, household_id, name, icon, amount_cents, previous_cents, next_due, note)
                    VALUES (\(bill.id), \(householdID), \(bill.name), \(bill.icon.rawValue), \(Int64(bill.amount.cents)), \(previous), \(due), \(bill.note))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
            for goal in household.goals {
                try await db.query(
                    """
                    INSERT INTO goals (id, household_id, name, image, saved_cents, target_cents)
                    VALUES (\(goal.id), \(householdID), \(goal.name), \(goal.image), \(Int64(goal.saved.cents)), \(Int64(goal.target.cents)))
                    ON CONFLICT DO NOTHING
                    """,
                    logger: logger
                )
            }
        }
        logger.info("Seeded sample household", metadata: ["transactions": "\(household.transactions.count)"])
    }

    static func memberRowID(_ id: MemberID) -> String {
        id == .maya ? "maya" : "jordan"
    }

    /// Transactions name their account the way the feed shows it. Most names match an account or a
    /// household sharing entry exactly; a card shown by issuer ("Northstar Visa") matches the account
    /// at that institution.
    static func accountRowID(forTransactionAccount name: String, in household: Household) -> String {
        if let exact = household.accounts.first(where: { $0.name == name }) { return exact.id }
        if let shared = household.sharedAccounts.first(where: { $0.name == name }) { return shared.id }
        let issuer = name.split(separator: " ").first.map(String.init) ?? name
        if let byInstitution = household.accounts.first(where: { $0.institution.hasPrefix(issuer) && $0.group == .liabilities })
            ?? household.accounts.first(where: { $0.institution.hasPrefix(issuer) }) {
            return byInstitution.id
        }
        return household.accounts.first { $0.group == .cash }?.id ?? household.accounts[0].id
    }

    static func date(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
