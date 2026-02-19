import Foundation
import Combine

/// Central manager for Sabbath mode state and logic
@MainActor
class SabbathManager: ObservableObject {
    static let shared = SabbathManager()

    @Published var state: SabbathModeState = .inactive
    @Published var schedule: SabbathSchedule
    @Published var config: SabbathModeConfig
    @Published var sabbathActivatedAt: Date?
    @Published var isAutoModeEnabled: Bool = false

    private let stateKey = "SabbathModeState"
    private let scheduleKey = "SabbathSchedule"
    private let configKey = "SabbathModeConfig"
    private let activatedAtKey = "SabbathActivatedAt"
    private let autoModeKey = "SabbathAutoMode"

    private init() {
        // Load persisted state
        if let rawState = UserDefaults.standard.string(forKey: stateKey),
           let savedState = SabbathModeState(rawValue: rawState) {
            self.state = savedState
        } else {
            self.state = .inactive
        }

        if let data = UserDefaults.standard.data(forKey: scheduleKey),
           let savedSchedule = try? JSONDecoder().decode(SabbathSchedule.self, from: data) {
            self.schedule = savedSchedule
        } else {
            self.schedule = SabbathSchedule()
        }

        if let data = UserDefaults.standard.data(forKey: configKey),
           let savedConfig = try? JSONDecoder().decode(SabbathModeConfig.self, from: data) {
            self.config = savedConfig
        } else {
            self.config = SabbathModeConfig()
        }

        if let date = UserDefaults.standard.object(forKey: activatedAtKey) as? Date {
            self.sabbathActivatedAt = date
        }

        self.isAutoModeEnabled = UserDefaults.standard.bool(forKey: autoModeKey)
    }

    // MARK: - Manual Sabbath Mode (Free Tier)

    /// Activate Sabbath mode manually
    func activateSabbathMode() {
        state = .active
        sabbathActivatedAt = Date()
        persistState()
        ScreenTimeManager.shared.enableRestrictions()
    }

    /// Deactivate Sabbath mode manually
    func deactivateSabbathMode() {
        state = .inactive
        sabbathActivatedAt = nil
        persistState()
        ScreenTimeManager.shared.disableRestrictions()
    }

    // MARK: - Automatic Sabbath Mode (Premium)

    /// Enable automatic scheduling based on the configured schedule
    func enableAutoMode() throws {
        let startComponents = DateComponents(
            hour: schedule.startHour,
            minute: schedule.startMinute,
            weekday: schedule.startDay.rawValue
        )
        let endComponents = DateComponents(
            hour: schedule.endHour,
            minute: schedule.endMinute,
            weekday: schedule.endDay.rawValue
        )

        try ScreenTimeManager.shared.scheduleDeviceActivity(
            start: startComponents,
            end: endComponents
        )

        isAutoModeEnabled = true
        state = .scheduled
        persistState()
    }

    /// Disable automatic scheduling
    func disableAutoMode() {
        ScreenTimeManager.shared.stopDeviceActivityMonitoring()
        isAutoModeEnabled = false
        if state == .scheduled {
            state = .inactive
        }
        persistState()
    }

    // MARK: - Schedule Management

    func updateSchedule(_ newSchedule: SabbathSchedule) {
        schedule = newSchedule
        persistSchedule()

        // Re-enable auto mode with the updated schedule if it was active
        if isAutoModeEnabled {
            try? enableAutoMode()
        }
    }

    // MARK: - Status Helpers

    /// Whether Sabbath mode is currently enforcing restrictions
    var isActive: Bool {
        state == .active
    }

    /// Formatted string of when Sabbath was activated
    var activatedTimeString: String? {
        guard let date = sabbathActivatedAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Formatted countdown to next Sabbath start
    var nextSabbathString: String? {
        guard let nextStart = schedule.nextStartDate() else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: nextStart, relativeTo: Date())
    }

    // MARK: - Persistence

    private func persistState() {
        UserDefaults.standard.set(state.rawValue, forKey: stateKey)
        UserDefaults.standard.set(sabbathActivatedAt, forKey: activatedAtKey)
        UserDefaults.standard.set(isAutoModeEnabled, forKey: autoModeKey)
    }

    private func persistSchedule() {
        if let data = try? JSONEncoder().encode(schedule) {
            UserDefaults.standard.set(data, forKey: scheduleKey)
        }
    }

    func persistConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
}
