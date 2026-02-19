import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var sabbathManager: SabbathManager
    @State private var showingPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Selection Summary
                    selectionSummary

                    // Select Apps Button
                    selectAppsButton

                    // Tips
                    tipsSection
                }
                .padding()
            }
            .navigationTitle("Select Apps")
            .background(Color(.systemGroupedBackground))
            .familyActivityPicker(
                isPresented: $showingPicker,
                selection: $screenTimeManager.activitySelection
            )
            .onChange(of: screenTimeManager.activitySelection) { _, newValue in
                screenTimeManager.updateSelection(newValue)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Choose Apps to Restrict")
                .font(.title3.bold())

            Text("Select the apps and categories you want to lock during Sabbath.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Selection Summary

    private var selectionSummary: some View {
        VStack(spacing: 12) {
            HStack {
                summaryItem(
                    count: screenTimeManager.selectedAppCount,
                    label: "Apps",
                    icon: "app.fill",
                    color: .blue
                )

                Divider()
                    .frame(height: 40)

                summaryItem(
                    count: screenTimeManager.selectedCategoryCount,
                    label: "Categories",
                    icon: "square.grid.2x2.fill",
                    color: .purple
                )
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func summaryItem(count: Int, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading) {
                Text("\(count)")
                    .font(.title2.bold())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Select Button

    private var selectAppsButton: some View {
        VStack(spacing: 12) {
            Button {
                showingPicker = true
            } label: {
                Label(
                    screenTimeManager.hasSelection ? "Modify Selection" : "Select Apps & Categories",
                    systemImage: "checklist"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!screenTimeManager.isAuthorized)

            if !screenTimeManager.isAuthorized {
                Text("Screen Time authorization is required to select apps.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let error = screenTimeManager.authorizationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(.headline)
                .padding(.bottom, 4)

            tipRow(
                icon: "lightbulb.fill",
                text: "Select entire categories like \"Social\" or \"Entertainment\" to block all related apps at once."
            )

            tipRow(
                icon: "star.fill",
                text: "Phone, Messages, and FaceTime can be individually selected to stay accessible."
            )

            tipRow(
                icon: "arrow.clockwise",
                text: "Your selection is saved and will persist between app launches."
            )
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.yellow)
                .frame(width: 20)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AppSelectionView()
        .environmentObject(ScreenTimeManager.shared)
        .environmentObject(SabbathManager.shared)
}
