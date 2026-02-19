import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sabbathManager: SabbathManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var premiumManager: PremiumManager
    @State private var showPaywall = false
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Premium Section
                premiumSection

                // Shield Configuration
                shieldSection

                // Data Management
                dataSection

                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Premium

    private var premiumSection: some View {
        Section("Subscription") {
            if premiumManager.isPremium {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("Premium Active")
                        .font(.body.bold())
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        VStack(alignment: .leading) {
                            Text("Upgrade to Premium")
                                .font(.body.bold())
                            Text("Automatic scheduling & more")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.primary)
            }

            Button("Restore Purchases") {
                Task {
                    await premiumManager.restorePurchases()
                }
            }
        }
    }

    // MARK: - Shield

    private var shieldSection: some View {
        Section {
            Toggle("Show Shield on Blocked Apps", isOn: $sabbathManager.config.showShield)
                .onChange(of: sabbathManager.config.showShield) { _, _ in
                    sabbathManager.persistConfig()
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("Shield Message")
                    .font(.subheadline)
                TextField("Enter shield message", text: $sabbathManager.config.shieldMessage)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .onChange(of: sabbathManager.config.shieldMessage) { _, _ in
                        sabbathManager.persistConfig()
                    }
            }

            Toggle("Allow Emergency Calls", isOn: $sabbathManager.config.allowEmergencyCalls)
                .onChange(of: sabbathManager.config.allowEmergencyCalls) { _, _ in
                    sabbathManager.persistConfig()
                }
        } header: {
            Text("Shield Configuration")
        } footer: {
            Text("Customize how blocked apps appear during Sabbath mode.")
        }
    }

    // MARK: - Data Management

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("Reset All Settings", systemImage: "trash")
            }
            .confirmationDialog(
                "Reset All Settings?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your app selection, schedule, and all preferences. This cannot be undone.")
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://sabbathlock.app/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.primary)

            Link(destination: URL(string: "https://sabbathlock.app/terms")!) {
                HStack {
                    Text("Terms of Service")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.primary)
        }
    }

    // MARK: - Helpers

    private func resetAll() {
        sabbathManager.deactivateSabbathMode()
        sabbathManager.disableAutoMode()
        screenTimeManager.clearStore()
        screenTimeManager.updateSelection(.init())
    }
}

#Preview {
    SettingsView()
        .environmentObject(SabbathManager.shared)
        .environmentObject(ScreenTimeManager.shared)
        .environmentObject(PremiumManager.shared)
}
