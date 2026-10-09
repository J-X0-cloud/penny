import Foundation
import Logging
import PennyCore
import PostgresNIO

/// Penny's Postgres schema. Money is stored in integer cents. Every statement is idempotent, so
/// `penny-server migrate` can run on each deploy.
public enum Schema {
    public static let statements: [String] = [
        """
        CREATE TABLE IF NOT EXISTS households (
            id          TEXT PRIMARY KEY,
            name        TEXT NOT NULL,
            split_mode  TEXT NOT NULL DEFAULT 'even' CHECK (split_mode IN ('even', 'by_income', 'custom')),
            created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS members (
            id                    TEXT PRIMARY KEY,
            household_id          TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
            name                  TEXT NOT NULL,
            email                 TEXT NOT NULL UNIQUE,
            initial               VARCHAR(2) NOT NULL,
            monthly_income_cents  BIGINT
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS accounts (
            id              TEXT PRIMARY KEY,
            household_id    TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
            owner_id        TEXT REFERENCES members(id),
            account_group   TEXT NOT NULL CHECK (account_group IN ('cash', 'investments', 'other_assets', 'liabilities')),
            name            TEXT NOT NULL,
            institution     TEXT NOT NULL,
            balance_cents   BIGINT NOT NULL,
            shared          BOOLEAN NOT NULL DEFAULT false,
            manual          BOOLEAN NOT NULL DEFAULT false,
            last_synced_at  TIMESTAMPTZ
        )
        """,
        "CREATE INDEX IF NOT EXISTS accounts_household_idx ON accounts (household_id)",
        """
        CREATE TABLE IF NOT EXISTS balance_snapshots (
            id             TEXT PRIMARY KEY,
            account_id     TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
            month          DATE NOT NULL,
            balance_cents  BIGINT NOT NULL,
            UNIQUE (account_id, month)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS categories (
            key    TEXT PRIMARY KEY,
            label  TEXT NOT NULL,
            icon   TEXT NOT NULL,
            fg     TEXT NOT NULL,
            bg     TEXT NOT NULL
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS budgets (
            id              TEXT PRIMARY KEY,
            household_id    TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
            category_key    TEXT NOT NULL REFERENCES categories(key),
            month           DATE NOT NULL,
            limit_cents     BIGINT NOT NULL,
            rollover_cents  BIGINT NOT NULL DEFAULT 0,
            UNIQUE (household_id, category_key, month)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS transactions (
            id            TEXT PRIMARY KEY,
            account_id    TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
            paid_by_id    TEXT REFERENCES members(id),
            category_key  TEXT NOT NULL REFERENCES categories(key),
            merchant      TEXT NOT NULL,
            amount_cents  BIGINT NOT NULL,
            posted_at     TIMESTAMPTZ NOT NULL,
            reviewed      BOOLEAN NOT NULL DEFAULT false,
            hidden        BOOLEAN NOT NULL DEFAULT false
        )
        """,
        "CREATE INDEX IF NOT EXISTS transactions_account_posted_idx ON transactions (account_id, posted_at)",
        "CREATE INDEX IF NOT EXISTS transactions_reviewed_idx ON transactions (reviewed)",
        """
        CREATE TABLE IF NOT EXISTS rules (
            id            TEXT PRIMARY KEY,
            pattern       TEXT NOT NULL,
            rename        TEXT,
            category_key  TEXT NOT NULL REFERENCES categories(key),
            applied_to    INTEGER NOT NULL DEFAULT 0,
            created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS bills (
            id              TEXT PRIMARY KEY,
            household_id    TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
            name            TEXT NOT NULL,
            icon            TEXT NOT NULL,
            amount_cents    BIGINT NOT NULL,
            previous_cents  BIGINT,
            next_due        DATE NOT NULL,
            note            TEXT
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS goals (
            id            TEXT PRIMARY KEY,
            household_id  TEXT NOT NULL REFERENCES households(id) ON DELETE CASCADE,
            name          TEXT NOT NULL,
            image         TEXT NOT NULL,
            saved_cents   BIGINT NOT NULL,
            target_cents  BIGINT NOT NULL,
            target_date   DATE,
            auto_cents    BIGINT
        )
        """,
    ]

    /// Creates any missing tables and indexes.
    public static func migrate(_ client: PostgresClient, logger: Logger) async throws {
        try await client.withTransaction(logger: logger) { connection in
            for statement in statements {
                try await connection.query(PostgresQuery(unsafeSQL: statement), logger: logger)
            }
        }
        logger.info("Schema is up to date", metadata: ["tables": "\(statements.filter { $0.contains("CREATE TABLE") }.count)"])
    }
}

extension AccountGroup {
    /// Column value in `accounts.account_group`.
    var databaseValue: String {
        switch self {
        case .cash: "cash"
        case .investments: "investments"
        case .otherAssets: "other_assets"
        case .liabilities: "liabilities"
        }
    }
}
