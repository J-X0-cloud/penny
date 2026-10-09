import PennyUI
import SwiftUI

@main
struct PennyApp: App {
    @State private var store = HouseholdStore.fromBundle()

    var body: some Scene {
        WindowGroup {
            PennyRootView(store: store)
                .preferredColorScheme(.light)
        }
    }
}
