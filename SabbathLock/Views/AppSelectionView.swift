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
                .foregroundStyle(.indigo)

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
        VStack(spacing: 0) {
            if screenTimeManager.hasSelection {
                // Total selection banner
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                    Text(screenTimeManager.selectionSummary)
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))

                Divider()

                // Breakdown row
                HStack(spacing: 0) {
                    summaryItem(
                        count: screenTimeManager.selectedAppCount,
                        label: "Apps",
                        icon: "app.fill",
                        color: .indigo
                    )

                    Divider()
                        .frame(height: 40)

                    summaryItem(
                        count: screenTimeManager.selectedCategoryCount,
                        label: "Categories",
                        icon: "square.grid.2x2.fill",
                        color: .purple
                    )

                    if screenTimeManager.selectedWebDomainCount > 0 {
                        Divider()
                            .frame(height: 40)

                        summaryItem(
                            count: screenTimeManager.selectedWebDomainCount,
                            label: "Websites",
                            icon: "globe",
                            color: .orange
                        )
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "app.dashed")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No apps or categories selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Tap the button below to get started")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryItem(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text("\(count)")
                .font(.title2.bold())
                .foregroundStyle(count > 0 ? .primary : .secondary)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
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
                    systemImage: screenTimeManager.hasSelection ? "pencil" : "plus.circle.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .disabled(!screenTimeManager.isAuthorized)

            if !screenTimeManager.isAuthorized {
                Label("Screen Time authorization is required to select apps.", systemImage: "exclamationmark.triangle.fill")
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
                color: .yellow,
                text: "Select entire categories like \"Social\" or \"Entertainment\" to block all related apps at once."
            )

            tipRow(
                icon: "star.fill",
                color: .indigo,
                text: "Phone, Messages, and FaceTime can be individually selected to stay accessible."
            )

            tipRow(
                icon: "arrow.clockwise",
                color: .green,
                text: "Your selection is saved and will persist between app launches."
            )
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func tipRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
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
