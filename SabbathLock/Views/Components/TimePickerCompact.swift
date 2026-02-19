import SwiftUI

/// A compact inline time picker using hour and minute wheels
struct TimePickerCompact: View {
    @Binding var hour: Int
    @Binding var minute: Int

    @State private var selectedDate: Date

    init(hour: Binding<Int>, minute: Binding<Int>) {
        _hour = hour
        _minute = minute
        var components = DateComponents()
        components.hour = hour.wrappedValue
        components.minute = minute.wrappedValue
        _selectedDate = State(initialValue: Calendar.current.date(from: components) ?? Date())
    }

    var body: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            displayedComponents: .hourAndMinute
        )
        .labelsHidden()
        .onChange(of: selectedDate) { _, newDate in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
            hour = components.hour ?? 0
            minute = components.minute ?? 0
        }
    }
}

#Preview {
    TimePickerCompact(hour: .constant(18), minute: .constant(0))
}
