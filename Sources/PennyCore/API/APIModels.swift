/// Wire formats for the Penny JSON API, shared by the server and the iPhone client.
public enum API {}

extension API {
    /// `GET /api/summary`: month-at-a-glance numbers for the Home screen and the web Overview.
    public struct Summary: Hashable, Sendable, Codable {
        public struct Period: Hashable, Sendable, Codable {
            public let month: String
            public let day: Int
            public let days: Int
        }

        public struct Spending: Hashable, Sendable, Codable {
            public let spent: Money
            public let budget: Money
            public let left: Money
            public let underPace: Money
        }

        public struct Bills: Hashable, Sendable, Codable {
            public let next30Days: Money
        }

        public struct NetWorth: Hashable, Sendable, Codable {
            public struct Group: Hashable, Sendable, Codable {
                public let group: AccountGroup
                public let total: Money
                public let count: Int
            }

            public let total: Money
            public let quarterChange: Money
            public let groups: [Group]
        }

        public struct HouseholdBalance: Hashable, Sendable, Codable {
            public let owedToMaya: Money
        }

        public let period: Period
        public let spending: Spending
        public let bills: Bills
        public let netWorth: NetWorth
        public let household: HouseholdBalance

        public init(household: Household) {
            period = Period(month: household.period.month, day: household.period.day, days: household.period.days)
            spending = Spending(
                spent: household.totalSpent, budget: household.totalBudget, left: household.leftToBudget,
                underPace: household.underPace
            )
            bills = Bills(next30Days: household.billsTotal)
            netWorth = NetWorth(
                total: household.netWorth,
                quarterChange: household.netWorthQuarterChange,
                groups: household.accountGroups.map { NetWorth.Group(group: $0.group, total: $0.total, count: $0.count) }
            )
            self.household = HouseholdBalance(owedToMaya: household.jordanOwes)
        }
    }

    /// A transaction as the clients display it: the date is already a label (`"Today"`, `"Sep 23"`).
    public struct TransactionResource: Hashable, Sendable, Codable, Identifiable {
        public let id: String
        public let merchant: String
        public let category: CategoryKey
        public let amount: Money
        public let date: String
        public let account: String
        public let paidBy: MemberID

        public init(_ transaction: Transaction, period: BudgetPeriod) {
            id = transaction.id
            merchant = transaction.merchant
            category = transaction.category
            amount = transaction.amount
            date = period.relativeLabel(for: transaction.postedOn)
            account = transaction.account
            paidBy = transaction.paidBy
        }
    }

    /// `GET /api/transactions`.
    public struct TransactionList: Hashable, Sendable, Codable {
        public let transactions: [TransactionResource]

        public init(transactions: [TransactionResource]) {
            self.transactions = transactions
        }
    }

    /// `PATCH /api/transactions` body.
    public struct Recategorize: Hashable, Sendable, Codable {
        public let id: String
        public let category: CategoryKey

        public init(id: String, category: CategoryKey) {
            self.id = id
            self.category = category
        }
    }

    /// `PATCH /api/transactions` response.
    public struct TransactionEnvelope: Hashable, Sendable, Codable {
        public let transaction: TransactionResource

        public init(transaction: TransactionResource) {
            self.transaction = transaction
        }
    }

    /// Error body for 4xx responses: either a message or per-field messages.
    public struct ErrorBody: Hashable, Sendable, Codable {
        public enum Detail: Hashable, Sendable, Codable {
            case message(String)
            case fields(ValidationError)

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let message = try? container.decode(String.self) {
                    self = .message(message)
                } else {
                    self = .fields(try container.decode(ValidationError.self))
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case let .message(message): try container.encode(message)
                case let .fields(errors): try container.encode(errors)
                }
            }
        }

        public let error: Detail

        public init(_ message: String) {
            error = .message(message)
        }

        public init(_ errors: ValidationError) {
            error = .fields(errors)
        }
    }
}
