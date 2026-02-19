import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sabbathManager: SabbathManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showDeactivateConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    statusCard

                    // Quick Action
                    actionButton

                    // Info Section
                    infoSection
                }
                .padding()
            }
            .navigationTitle("SabbathLock")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        VStack(spacing: 16) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: statusIcon)
                    .font(.system(size: 44))
                    .foregroundStyle(statusColor)
            }

            // Status text
            Text(statusTitle)
                .font(.title2.bold())

            Text(statusSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Active since
            if sabbathManager.isActive, let time = sabbathManager.activatedTimeString {
                HStack {
                    Image(systemName: "clock")
                    Text("Active since \(time)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Group {
            if sabbathManager.isActive {
                Button {
                    showDeactivateConfirmation = true
                } label: {
                    Label("End Sabbath Mode", systemImage: "lock.open.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .confirmationDialog(
                    "End Sabbath Mode?",
                    isPresented: $showDeactivateConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("End Sabbath Mode", role: .destructive) {
                        withAnimation {
                            sabbathManager.deactivateSabbathMode()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will unlock all restricted apps.")
                }
            } else {
                Button {
                    withAnimation {
                        sabbathManager.activateSabbathMode()
                    }
                } label: {
                    Label("Start Sabbath Mode", systemImage: "lock.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!screenTimeManager.hasSelection || !screenTimeManager.isAuthorized)
            }
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !screenTimeManager.isAuthorized {
                infoRow(
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: "Screen Time Permission Required",
                    subtitle: "Grant permission to enable app restrictions."
                )
            }

            if !screenTimeManager.hasSelection {
                infoRow(
                    icon: "app.badge",
                    color: .blue,
                    title: "No Apps Selected",
                    subtitle: "Go to the Apps tab to select apps to restrict."
                )
            }

            if let nextSabbath = sabbathManager.nextSabbathString, !sabbathManager.isActive {
                infoRow(
                    icon: "calendar",
                    color: .purple,
                    title: "Next Sabbath",
                    subtitle: nextSabbath
                )
            }

            if sabbathManager.isAutoModeEnabled {
                infoRow(
                    icon: "clock.badge.checkmark.fill",
                    color: .green,
                    title: "Auto Mode Active",
                    subtitle: "Sabbath mode will activate automatically on schedule."
                )
            }
        }
    }

    private func infoRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Computed Properties

    private var statusColor: Color {
        switch sabbathManager.state {
        case .active: return .green
        case .scheduled: return .orange
        case .inactive: return .secondary
        }
    }

    private var statusIcon: String {
        switch sabbathManager.state {
        case .active: return "lock.fill"
        case .scheduled: return "clock.badge.checkmark.fill"
        case .inactive: return "lock.open"
        }
    }

    private var statusTitle: String {
        switch sabbathManager.state {
        case .active: return "Sabbath Mode Active"
        case .scheduled: return "Sabbath Scheduled"
        case .inactive: return "Sabbath Mode Off"
        }
    }

    private var statusSubtitle: String {
        switch sabbathManager.state {
        case .active:
            let count = screenTimeManager.selectedAppCount + screenTimeManager.selectedCategoryCount
            return "\(count) app\(count == 1 ? "" : "s")/categor\(count == 1 ? "y" : "ies") restricted"
        case .scheduled:
            return "Will activate automatically at the scheduled time"
        case .inactive:
            return "Tap the button below to enter Sabbath mode"
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ScreenTimeManager.shared)
        .environmentObject(SabbathManager.shared)
        .environmentObject(PremiumManager.shared)
}
