import Foundation

/// Represents the current state of Sabbath mode
enum SabbathModeState: String, Codable {
    case inactive
    case active
    case scheduled
}

/// Configuration for what happens during Sabbath mode
struct SabbathModeConfig: Codable {
    /// Whether to show a shield over blocked apps
    var showShield: Bool = true
    /// Custom message to display on the shield
    var shieldMessage: String = "Shabbat Shalom! This app is locked during Sabbath."
    /// Whether to allow emergency calls
    var allowEmergencyCalls: Bool = true
    /// Whether to allow specific contacts
    var allowedContactsEnabled: Bool = false
}
