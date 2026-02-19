import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var sabbathManager: SabbathManager

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            AppSelectionView()
                .tabItem {
                    Label("Apps", systemImage: "app.badge.checkmark")
                }

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar.badge.clock")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(ScreenTimeManager.shared)
        .environmentObject(SabbathManager.shared)
        .environmentObject(PremiumManager.shared)
}
