/// How a two-person household divides shared spending.
public enum SplitPolicy: Hashable, Sendable, Codable {
    /// 50 / 50.
    case even
    /// In proportion to each member's monthly income (falls back to even when incomes are unknown).
    case byIncome
    /// A fixed share for Maya, 0...100; Jordan takes the rest.
    case custom(mayaPercent: Double)

    /// Label shown on the settle-up card, e.g. `"Split 50 / 50"`.
    public func label(shares: [MemberID: Double]) -> String {
        switch self {
        case .even:
            return "Split 50 / 50"
        case .byIncome, .custom:
            let maya = Int(((shares[.maya] ?? 0.5) * 100).rounded(.toNearestOrAwayFromZero))
            return "Split \(maya) / \(100 - maya)"
        }
    }
}

/// Who owes whom after applying the split to what each member actually paid.
public struct SettleUpBalance: Hashable, Sendable, Codable {
    /// The member who paid less than their share. `nil` when the household is square.
    public let debtor: MemberID?
    public let creditor: MemberID?
    public let amount: Money

    public static let square = SettleUpBalance(debtor: nil, creditor: nil, amount: .zero)

    public init(debtor: MemberID?, creditor: MemberID?, amount: Money) {
        self.debtor = debtor
        self.creditor = creditor
        self.amount = amount
    }

    public var isSettled: Bool { amount == .zero }

    /// What `member` owes `other` under this balance (zero if the debt runs the other way).
    public func owed(from member: MemberID, to other: MemberID) -> Money {
        debtor == member && creditor == other ? amount : .zero
    }
}

public enum SplitCalculator {
    /// Each member's share of shared spending as a fraction; the values sum to 1.
    public static func shares(for policy: SplitPolicy, members: [Member]) -> [MemberID: Double] {
        switch policy {
        case .even:
            return [.maya: 0.5, .jordan: 0.5]
        case let .custom(mayaPercent):
            let maya = min(max(mayaPercent, 0), 100) / 100
            return [.maya: maya, .jordan: 1 - maya]
        case .byIncome:
            let incomes = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0.monthlyIncome ?? .zero) })
            let total = incomes.values.sum()
            guard total > .zero, let maya = incomes[.maya] else { return shares(for: .even, members: members) }
            let fraction = maya.fraction(of: total)
            return [.maya: fraction, .jordan: 1 - fraction]
        }
    }

    /// Settle-up balance for a month of shared spending.
    ///
    /// Each member's fair share is the total times their split fraction (Maya's share is rounded to
    /// the cent and Jordan takes the remainder, so the shares always add back to the total). The
    /// member who paid less than their share owes the difference.
    public static func balance(paid: [MemberID: Money], policy: SplitPolicy, members: [Member]) -> SettleUpBalance {
        let total = paid.values.sum()
        let fractions = shares(for: policy, members: members)
        let mayaShare: Money
        if policy == .even {
            mayaShare = total.split(into: 2)[0]
        } else {
            mayaShare = total.scaled(by: fractions[.maya] ?? 0.5)
        }
        let jordanShare = total - mayaShare
        let jordanPaid = paid[.jordan] ?? .zero
        // Positive: Jordan paid less than their share and owes Maya.
        let jordanOwes = jordanShare - jordanPaid
        if jordanOwes > .zero {
            return SettleUpBalance(debtor: .jordan, creditor: .maya, amount: jordanOwes)
        } else if jordanOwes < .zero {
            return SettleUpBalance(debtor: .maya, creditor: .jordan, amount: -jordanOwes)
        }
        return .square
    }

    /// Balance from individual shared purchases rather than monthly totals.
    public static func balance(entries: [LedgerEntry], policy: SplitPolicy, members: [Member]) -> SettleUpBalance {
        var paid: [MemberID: Money] = [:]
        for entry in entries {
            paid[entry.paidBy, default: .zero] += entry.amount
        }
        return balance(paid: paid, policy: policy, members: members)
    }
}

// MARK: - Settling up

public enum SettlementMethod: String, CaseIterable, Codable, Sendable {
    case transfer, cash, other
}

/// A request to record a settle-up payment between the two members.
public struct SettleUpRequest: Hashable, Sendable, Codable {
    public var from: MemberID
    public var to: MemberID
    public var amount: Money
    public var method: SettlementMethod

    public init(from: MemberID, to: MemberID, amount: Money, method: SettlementMethod = .transfer) {
        self.from = from
        self.to = to
        self.amount = amount
        self.method = method
    }
}

/// A recorded settle-up payment.
public struct Settlement: Hashable, Sendable, Codable {
    public let from: MemberID
    public let to: MemberID
    public let amount: Money
    public let method: SettlementMethod
    /// ISO-8601 timestamp.
    public let recordedAt: String
}

public struct SettlementResult: Hashable, Sendable, Codable {
    public struct Balance: Hashable, Sendable, Codable {
        public let remaining: Money
        public let settled: Bool
    }

    public let settlement: Settlement
    public let balance: Balance
}

/// Why a settle-up payment was rejected.
public enum SettlementError: Error, Hashable, Sendable {
    /// One or more fields are invalid.
    case invalidFields(ValidationError)
    /// The payment names the same member as payer and payee.
    case sameMember

    public var message: String {
        switch self {
        case let .invalidFields(errors): errors.description
        case .sameMember: "Choose two different members"
        }
    }
}

public enum SettlementService {
    /// Validates a settle-up payment and works out what is left to pay.
    ///
    /// - Parameters:
    ///   - request: The payment being recorded.
    ///   - balance: The household's current balance.
    ///   - recordedAt: Timestamp to stamp on the settlement.
    /// - Throws: ``SettlementError/invalidFields(_:)`` when the amount is not a positive number of
    ///   cents, then ``SettlementError/sameMember`` when payer and payee are the same person.
    public static func settle(
        _ request: SettleUpRequest, against balance: SettleUpBalance, recordedAt: String
    ) throws(SettlementError) -> SettlementResult {
        if request.amount <= .zero {
            throw .invalidFields(ValidationError(field: "amount", "Number must be greater than 0"))
        }
        if request.from == request.to {
            throw .sameMember
        }

        let outstanding = balance.owed(from: request.from, to: request.to)
        let remaining = max(outstanding - request.amount, .zero)
        return SettlementResult(
            settlement: Settlement(
                from: request.from, to: request.to, amount: request.amount, method: request.method,
                recordedAt: recordedAt
            ),
            balance: .init(remaining: remaining, settled: remaining == .zero)
        )
    }
}
