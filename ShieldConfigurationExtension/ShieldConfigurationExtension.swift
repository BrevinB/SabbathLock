import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Provides custom shield UI when a user tries to open a blocked app during Sabbath.
class SabbathShieldConfiguration: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return buildShieldConfig()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return buildShieldConfig()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return buildShieldConfig()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return buildShieldConfig()
    }

    private func buildShieldConfig() -> ShieldConfiguration {
        let message = UserDefaults.standard.string(forKey: "ShieldMessage")
            ?? "Shabbat Shalom! This app is locked during Sabbath."

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "moon.stars.fill"),
            title: ShieldConfiguration.Label(
                text: "Sabbath Mode",
                color: UIColor.label
            ),
            subtitle: ShieldConfiguration.Label(
                text: message,
                color: UIColor.secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: UIColor.white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue
        )
    }
}
