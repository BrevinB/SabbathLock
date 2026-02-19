import SwiftUI
import FamilyControls

@main
struct SabbathLockApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @StateObject private var sabbathManager = SabbathManager.shared
    @StateObject private var premiumManager = PremiumManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenTimeManager)
                .environmentObject(sabbathManager)
                .environmentObject(premiumManager)
                .task {
                    await screenTimeManager.requestAuthorization()
                }
        }
    }
}
