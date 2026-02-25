import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var sabbathManager: SabbathManager
    @EnvironmentObject var premiumManager: PremiumManager
    @State private var showPaywall = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // Auto Mode Toggle
                Section {
                    autoModeToggle
                } header: {
                    Text("Automatic Mode")
                } footer: {
                    Text("When enabled, Sabbath mode will automatically activate and deactivate based on your schedule.")
                }

                // Schedule Configuration
                Section("Sabbath Start") {
                    startDayPicker
                    startTimePicker
                }

                Section("Sabbath End") {
                    endDayPicker
                    endTimePicker
                }

                // Schedule Preview
                Section("Preview") {
                    schedulePreview
                }
            }
            .navigationTitle("Schedule")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Schedule Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Auto Mode Toggle

    private var autoModeToggle: some View {
        Toggle(isOn: Binding(
            get: { sabbathManager.isAutoModeEnabled },
            set: { newValue in
                if newValue {
                    if premiumManager.canUseAutoSchedule {
                        enableAutoMode()
                    } else {
                        showPaywall = true
                    }
                } else {
                    sabbathManager.disableAutoMode()
                }
            }
        )) {
            HStack {
                Image(systemName: "clock.badge.checkmark.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading) {
                    Text("Auto Sabbath Mode")
                        .font(.body)
                    if !premiumManager.isPremium {
                        Text("Premium Feature")
                            .font(.caption)
                            .foregroundStyle(.indigo)
                    }
                }
            }
        }
    }

    // MARK: - Day & Time Pickers

    private var startDayPicker: some View {
        Picker("Day", selection: $sabbathManager.schedule.startDay) {
            ForEach(SabbathSchedule.Weekday.allCases) { day in
                Text(day.displayName).tag(day)
            }
        }
        .onChange(of: sabbathManager.schedule.startDay) { _, _ in
            sabbathManager.updateSchedule(sabbathManager.schedule)
        }
    }

    private var startTimePicker: some View {
        HStack {
            Text("Time")
            Spacer()
            TimePickerCompact(
                hour: $sabbathManager.schedule.startHour,
                minute: $sabbathManager.schedule.startMinute
            )
        }
    }

    private var endDayPicker: some View {
        Picker("Day", selection: $sabbathManager.schedule.endDay) {
            ForEach(SabbathSchedule.Weekday.allCases) { day in
                Text(day.displayName).tag(day)
            }
        }
        .onChange(of: sabbathManager.schedule.endDay) { _, _ in
            sabbathManager.updateSchedule(sabbathManager.schedule)
        }
    }

    private var endTimePicker: some View {
        HStack {
            Text("Time")
            Spacer()
            TimePickerCompact(
                hour: $sabbathManager.schedule.endHour,
                minute: $sabbathManager.schedule.endMinute
            )
        }
    }

    // MARK: - Preview

    private var schedulePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sunset.fill")
                    .foregroundStyle(.orange)
                Text("Starts: \(sabbathManager.schedule.startDay.displayName) at \(formattedTime(sabbathManager.schedule.startHour, sabbathManager.schedule.startMinute))")
            }
            HStack {
                Image(systemName: "sunrise.fill")
                    .foregroundStyle(.yellow)
                Text("Ends: \(sabbathManager.schedule.endDay.displayName) at \(formattedTime(sabbathManager.schedule.endHour, sabbathManager.schedule.endMinute))")
            }

            if let next = sabbathManager.nextSabbathString {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.purple)
                    Text("Next: \(next)")
                }
                .padding(.top, 4)
            }
        }
        .font(.subheadline)
    }

    // MARK: - Helpers

    private func enableAutoMode() {
        do {
            try sabbathManager.enableAutoMode()
        } catch {
            errorMessage = "Failed to enable auto mode: \(error.localizedDescription)"
            showError = true
        }
    }

    private func formattedTime(_ hour: Int, _ minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduleView()
        .environmentObject(SabbathManager.shared)
        .environmentObject(PremiumManager.shared)
}
