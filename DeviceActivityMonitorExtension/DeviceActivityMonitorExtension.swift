import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

/// Extension that monitors device activity and enforces Sabbath restrictions.
/// This runs as a separate process and is invoked by the system when the scheduled
/// Device Activity interval starts or ends.
class SabbathDeviceActivityMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()

    /// Called when the Sabbath interval begins
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        guard activity.rawValue == "SabbathMode" else { return }

        // Load the saved selection and apply shields
        let selection = loadSavedSelection()
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens

        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy<Application>.specific(categories)
        store.shield.webDomains = webDomains.isEmpty ? nil : webDomains
        store.shield.webDomainCategories = categories.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy<WebDomain>.specific(categories)

        // Persist the active state
        UserDefaults.standard.set(SabbathModeState.active.rawValue, forKey: "SabbathModeState")
    }

    /// Called when the Sabbath interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        guard activity.rawValue == "SabbathMode" else { return }

        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil

        // Persist the inactive state
        UserDefaults.standard.set(SabbathModeState.inactive.rawValue, forKey: "SabbathModeState")
    }

    /// Called when the schedule warning time is reached (15 min before start)
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        // Could trigger a local notification here
    }

    /// Called when the schedule warning time before end is reached
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    // MARK: - Helpers

    private func loadSavedSelection() -> FamilyActivitySelection {
        guard let data = UserDefaults.standard.data(forKey: "SavedFamilyActivitySelection") else {
            return FamilyActivitySelection()
        }
        return (try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)) ?? FamilyActivitySelection()
    }
}
