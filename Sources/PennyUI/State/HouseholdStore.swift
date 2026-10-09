#if os(iOS)
import Observation
import PennyClient
import PennyCore
import SwiftUI

/// App state for the five tabs. Edits apply to the local household first so the UI responds
/// instantly; when a server is configured they are then sent to the API, and a failure rolls the
/// edit back and surfaces a message.
@MainActor
@Observable
public final class HouseholdStore {
    public private(set) var household: Household
    /// The settle-up recorded this session, if any.
    public private(set) var settlement: SettlementResult?
    /// Set when an API call fails; the root view shows it as an alert.
    public var errorMessage: String?

    private let client: PennyAPIClient?
    private let now: () -> Date

    /// - Parameters:
    ///   - household: Data to show; development builds use the bundled sample.
    ///   - client: API to sync with. `nil` keeps everything on the device.
    public init(household: Household = .sample, client: PennyAPIClient? = nil, now: @escaping () -> Date = Date.init) {
        self.household = household
        self.client = client
        self.now = now
    }

    /// A store configured from the app's Info.plist: `PennyAPIBaseURL` turns on server sync.
    public static func fromBundle(_ bundle: Bundle = .main) -> HouseholdStore {
        let base = (bundle.object(forInfoDictionaryKey: "PennyAPIBaseURL") as? String)
            .flatMap { $0.isEmpty ? nil : URL(string: $0) }
        return HouseholdStore(client: base.map { PennyAPIClient(baseURL: $0) })
    }

    // MARK: Review queue

    /// The first few transactions waiting for review, as shown on Home.
    public var reviewPreview: [Transaction] {
        Array(household.unreviewedTransactions.prefix(2))
    }

    public func recategorize(_ transaction: Transaction, to category: CategoryKey) async {
        let previous = household
        household.recategorize(transactionID: transaction.id, to: category)
        guard let client else { return }
        do {
            _ = try await client.recategorize(transactionID: transaction.id, to: category)
        } catch {
            household = previous
            errorMessage = (error as? PennyAPIError)?.message ?? error.localizedDescription
        }
    }

    // MARK: Sharing

    /// Flips whether an account is visible to the whole household.
    public func setShared(_ shared: Bool, accountID: String) {
        guard let index = household.sharedAccounts.firstIndex(where: { $0.id == accountID }) else { return }
        household.sharedAccounts[index].shared = shared
    }

    // MARK: Settle up

    public var isSettled: Bool { settlement?.balance.settled ?? household.settleUpBalance.isSettled }

    /// The line on the settle-up card.
    public var settleUpSummary: String {
        if isSettled { return "All square this month" }
        let balance = household.settleUpBalance
        guard let debtor = balance.debtor, let creditor = balance.creditor else { return "All square this month" }
        let remaining = settlement?.balance.remaining ?? balance.amount
        let you = MemberID.maya
        if creditor == you {
            return "\(household.member(debtor).name) owes you \(remaining.formatted)"
        }
        return "You owe \(household.member(creditor).name) \(remaining.formatted)"
    }

    /// Records a payment for the full outstanding balance.
    public func settleUp(method: SettlementMethod = .transfer) async {
        let balance = household.settleUpBalance
        guard let debtor = balance.debtor, let creditor = balance.creditor, !isSettled else { return }
        let request = SettleUpRequest(from: debtor, to: creditor, amount: balance.amount, method: method)
        do {
            if let client {
                settlement = try await client.settle(request)
            } else {
                settlement = try SettlementService.settle(request, against: balance, recordedAt: now().ISO8601Format())
            }
        } catch let error as PennyAPIError {
            errorMessage = error.message
        } catch let error as SettlementError {
            errorMessage = error.message
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
