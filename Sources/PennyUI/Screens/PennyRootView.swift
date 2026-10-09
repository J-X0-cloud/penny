#if os(iOS)
import LocalAuthentication
import PennyCore
import SwiftUI

/// The app's root: five tabs behind a Face ID / passcode lock that re-engages every time the app
/// comes back to the foreground. Balances are hidden in the app switcher.
public struct PennyRootView: View {
    @State private var store: HouseholdStore
    @State private var selectedTab: AppScreen = .home
    @State private var lock = AppLock()
    @Environment(\.scenePhase) private var scenePhase

    public init(store: HouseholdStore) {
        _store = State(initialValue: store)
    }

    public var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(AppScreen.allCases) { screen in
                    content(for: screen)
                        .tabItem {
                            Label {
                                Text(screen.title)
                            } icon: {
                                Image(uiImage: TabIconRenderer.image(for: screen.icon))
                            }
                        }
                        .tag(screen)
                }
            }
            .tint(Theme.violet)
            .environment(store)

            if lock.isLocked || scenePhase != .active {
                LockScreen(isLocked: lock.isLocked) {
                    Task { await lock.unlock() }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: lock.isLocked)
        .alert("Something went wrong", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.errorMessage ?? "")
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: lock.lock()
            case .active: Task { await lock.unlockIfNeeded() }
            default: break
            }
        }
        .task { await lock.unlockIfNeeded() }
    }

    @ViewBuilder
    private func content(for screen: AppScreen) -> some View {
        switch screen {
        case .home: HomeView(selectedTab: $selectedTab)
        case .budgets: BudgetsView()
        case .bills: BillsView()
        case .netWorth: NetWorthView()
        case .household: HouseholdView()
        }
    }
}

/// Face ID / passcode gate. Devices without any biometrics or passcode stay unlocked.
@MainActor
@Observable
final class AppLock {
    private(set) var isLocked = true
    private var isAuthenticating = false

    func lock() {
        isLocked = true
    }

    func unlockIfNeeded() async {
        guard isLocked else { return }
        await unlock()
    }

    func unlock() async {
        guard !isAuthenticating else { return }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // Nothing to authenticate with (e.g. a simulator with no passcode).
            isLocked = false
            return
        }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your balances")
            isLocked = !success
        } catch {
            isLocked = true
        }
    }
}

private struct LockScreen: View {
    let isLocked: Bool
    let unlock: () -> Void

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 16) {
                PennyIcon(name: .lock, color: Theme.violet, size: 40)
                Text("Penny is locked")
                    .font(Typography.serif(24, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                if isLocked {
                    Button(action: unlock) {
                        Label("Unlock", systemImage: "faceid")
                            .font(Typography.sans(15, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Theme.violet, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// Tab-bar items need template images, so the line icons are rendered once into `UIImage`s.
@MainActor
enum TabIconRenderer {
    private static var cache: [IconName: UIImage] = [:]

    static func image(for icon: IconName) -> UIImage {
        if let cached = cache[icon] { return cached }
        let renderer = ImageRenderer(content: PennyIcon(name: icon, color: .black, size: 23))
        renderer.scale = UITraitCollection.current.displayScale
        let image = (renderer.uiImage ?? UIImage()).withRenderingMode(.alwaysTemplate)
        cache[icon] = image
        return image
    }
}
#endif
