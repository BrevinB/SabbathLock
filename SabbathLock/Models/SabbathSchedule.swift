import Foundation

/// Represents the Sabbath schedule configuration
struct SabbathSchedule: Codable, Equatable {
    /// Day the Sabbath starts (default: Friday)
    var startDay: Weekday = .friday
    /// Hour the Sabbath starts in 24h format (default: sunset ~18:00)
    var startHour: Int = 18
    /// Minute the Sabbath starts
    var startMinute: Int = 0
    /// Day the Sabbath ends (default: Saturday)
    var endDay: Weekday = .saturday
    /// Hour the Sabbath ends in 24h format (default: nightfall ~19:30)
    var endHour: Int = 19
    /// Minute the Sabbath ends
    var endMinute: Int = 30

    enum Weekday: Int, Codable, CaseIterable, Identifiable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

        var id: Int { rawValue }

        var displayName: String {
            switch self {
            case .sunday: return "Sunday"
            case .monday: return "Monday"
            case .tuesday: return "Tuesday"
            case .wednesday: return "Wednesday"
            case .thursday: return "Thursday"
            case .friday: return "Friday"
            case .saturday: return "Saturday"
            }
        }
    }

    /// Returns the next upcoming start date from now
    func nextStartDate(from date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekday = startDay.rawValue
        components.hour = startHour
        components.minute = startMinute
        components.second = 0
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
    }

    /// Returns the next upcoming end date from now
    func nextEndDate(from date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekday = endDay.rawValue
        components.hour = endHour
        components.minute = endMinute
        components.second = 0
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
    }

    /// Check if a given date falls within the Sabbath window
    func isWithinSabbath(date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let currentMinutes = hour * 60 + minute

        let startWeekday = startDay.rawValue
        let endWeekday = endDay.rawValue
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        if startWeekday == endWeekday {
            return weekday == startWeekday && currentMinutes >= startMinutes && currentMinutes < endMinutes
        }

        // Sabbath spans across days (e.g., Friday evening to Saturday evening)
        if weekday == startWeekday && currentMinutes >= startMinutes {
            return true
        }
        if weekday == endWeekday && currentMinutes < endMinutes {
            return true
        }

        // Check if the current day is between start and end days
        if startWeekday < endWeekday {
            return weekday > startWeekday && weekday < endWeekday
        } else {
            // Wraps around the week (e.g., Saturday to Sunday)
            return weekday > startWeekday || weekday < endWeekday
        }
    }
}
