# SabbathLock

A SwiftUI iOS app that helps users disconnect from their phone during the Sabbath by restricting access to selected apps using Apple's ScreenTime API.

## Features

### Free Tier
- **App Selection** — Choose which apps and categories to restrict during Sabbath
- **Manual Sabbath Mode** — Tap a button to activate restrictions; tap again to deactivate
- **Custom Shield** — Blocked apps show a "Shabbat Shalom" shield overlay
- **Persistent Settings** — Your app selection and preferences are saved between launches

### Premium Tier (In-App Subscription)
- **Automatic Scheduling** — Set your Sabbath start/end times and restrictions activate automatically each week
- **Custom Shield Messages** — Personalize the message shown on blocked apps
- **Smart Notifications** — Get a 15-minute warning before Sabbath mode activates

## Architecture

```
SabbathLock/
├── App/
│   ├── SabbathLockApp.swift          # App entry point
│   └── Info.plist                     # App configuration
├── Models/
│   ├── SabbathSchedule.swift          # Schedule data model
│   └── SabbathMode.swift              # Mode state & config models
├── Views/
│   ├── ContentView.swift              # Tab bar root view
│   ├── HomeView.swift                 # Status dashboard & manual toggle
│   ├── AppSelectionView.swift         # FamilyActivityPicker integration
│   ├── ScheduleView.swift             # Sabbath time configuration
│   ├── SettingsView.swift             # Preferences & premium management
│   ├── PaywallView.swift              # Subscription purchase UI
│   └── Components/
│       ├── TimePickerCompact.swift    # Inline time picker
│       └── SabbathStatusBadge.swift   # Status indicator badge
├── Services/
│   ├── ScreenTimeManager.swift        # ScreenTime API integration
│   ├── SabbathManager.swift           # Core Sabbath mode logic
│   └── PremiumManager.swift           # StoreKit 2 subscriptions
├── Assets.xcassets/                   # App icons & colors
└── SabbathLock.entitlements           # Family Controls entitlement

DeviceActivityMonitorExtension/        # Monitors scheduled Sabbath intervals
ShieldConfigurationExtension/          # Custom shield UI for blocked apps
ShieldActionExtension/                 # Handles shield button actions
```

## Requirements

- **Xcode 15.4+**
- **iOS 17.0+**
- **Swift 5.9+**
- **Apple Developer Account** with Family Controls capability enabled

## Setup

1. Clone the repository
2. Open `SabbathLock.xcodeproj` in Xcode
3. Select your Development Team in Signing & Capabilities for all 4 targets:
   - SabbathLock
   - DeviceActivityMonitorExtension
   - ShieldConfigurationExtension
   - ShieldActionExtension
4. Enable the **Family Controls** capability on your App ID in the Apple Developer Portal
5. Build and run on a physical device (ScreenTime APIs don't work in Simulator)

## Frameworks Used

| Framework | Purpose |
|-----------|---------|
| `FamilyControls` | Authorization & app picker for selecting apps to restrict |
| `ManagedSettings` | Applying and removing app shields/restrictions |
| `DeviceActivity` | Scheduling automatic Sabbath intervals |
| `ManagedSettingsUI` | Custom shield configuration |
| `StoreKit` | In-app subscription management (StoreKit 2) |

## Important Notes

- **Physical device required** — ScreenTime/Family Controls APIs are not available in the iOS Simulator
- **Family Controls entitlement** — You must request this entitlement from Apple via your developer account
- **App Groups** — For production, consider using App Groups to share UserDefaults between the main app and extensions
- **StoreKit Testing** — Use Xcode's StoreKit Configuration file for testing in-app purchases during development
