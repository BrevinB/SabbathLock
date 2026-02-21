import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

/// Manages all ScreenTime API interactions for app selection and restriction
@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var isAuthorized: Bool = false
    @Published var authorizationError: String?
    @Published var activitySelection = FamilyActivitySelection()

    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared

    /// Key for persisting the encoded activity selection
    private let selectionKey = "SavedFamilyActivitySelection"

    private init() {
        loadSavedSelection()
    }

    // MARK: - Authorization

    /// Request ScreenTime authorization from the user
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(for: .individual)
            isAuthorized = true
            authorizationError = nil
        } catch {
            isAuthorized = false
            authorizationError = "Screen Time authorization denied. Please enable it in Settings > Screen Time."
        }
    }

    // MARK: - App Selection

    /// Update the selected apps/categories to restrict
    func updateSelection(_ selection: FamilyActivitySelection) {
        activitySelection = selection
        saveSelection(selection)
    }

    /// Save the selection to UserDefaults via encoding
    private func saveSelection(_ selection: FamilyActivitySelection) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(selection) {
            UserDefaults.standard.set(data, forKey: selectionKey)
        }
    }

    /// Load previously saved selection
    private func loadSavedSelection() {
        guard let data = UserDefaults.standard.data(forKey: selectionKey) else { return }
        let decoder = JSONDecoder()
        if let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            activitySelection = selection
        }
    }

    // MARK: - Shield / Restriction Management

    /// Enable restrictions on selected apps
    func enableRestrictions() {
        let applications = activitySelection.applicationTokens
        let categories = activitySelection.categoryTokens
        let webDomains = activitySelection.webDomainTokens

        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy<Application>.specific(categories)
        store.shield.webDomains = webDomains.isEmpty ? nil : webDomains
        store.shield.webDomainCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy<WebDomain>.specific(categories)
    }

    /// Remove all restrictions
    func disableRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
    }

    /// Clear the managed settings store entirely
    func clearStore() {
        store.clearAllSettings()
    }

    // MARK: - Device Activity Scheduling

    /// Schedule a Device Activity monitoring interval for automatic Sabbath mode
    func scheduleDeviceActivity(start: DateComponents, end: DateComponents, name: String = "SabbathMode") throws {
        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: true,
            warningTime: DateComponents(minute: 15)
        )

        let activityName = DeviceActivityName(rawValue: name)
        let center = DeviceActivityCenter()

        try center.startMonitoring(activityName, during: schedule)
    }

    /// Stop monitoring a scheduled Device Activity
    func stopDeviceActivityMonitoring(name: String = "SabbathMode") {
        let activityName = DeviceActivityName(rawValue: name)
        let center = DeviceActivityCenter()
        center.stopMonitoring([activityName])
    }

    /// Stop all Device Activity monitoring
    func stopAllMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring()
    }

    /// Check how many apps are currently selected
    var selectedAppCount: Int {
        activitySelection.applicationTokens.count
    }

    /// Check how many categories are selected
    var selectedCategoryCount: Int {
        activitySelection.categoryTokens.count
    }

    /// Check how many web domains are selected
    var selectedWebDomainCount: Int {
        activitySelection.webDomainTokens.count
    }

    /// Total number of individual items selected across all types
    var totalSelectionCount: Int {
        selectedAppCount + selectedCategoryCount + selectedWebDomainCount
    }

    /// Whether any apps or categories have been selected
    var hasSelection: Bool {
        !activitySelection.applicationTokens.isEmpty ||
        !activitySelection.categoryTokens.isEmpty ||
        !activitySelection.webDomainTokens.isEmpty
    }

    /// Human-readable summary of the current selection
    var selectionSummary: String {
        guard hasSelection else { return "No apps selected" }

        var parts: [String] = []
        if selectedAppCount > 0 {
            parts.append("\(selectedAppCount) app\(selectedAppCount == 1 ? "" : "s")")
        }
        if selectedCategoryCount > 0 {
            parts.append("\(selectedCategoryCount) categor\(selectedCategoryCount == 1 ? "y" : "ies")")
        }
        if selectedWebDomainCount > 0 {
            parts.append("\(selectedWebDomainCount) website\(selectedWebDomainCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }
}
