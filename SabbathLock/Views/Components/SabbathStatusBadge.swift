import SwiftUI

/// A small badge indicating the current Sabbath mode status
struct SabbathStatusBadge: View {
    let state: SabbathModeState

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption2.bold())
                .textCase(.uppercase)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15), in: Capsule())
    }

    private var color: Color {
        switch state {
        case .active: return .green
        case .scheduled: return .orange
        case .inactive: return .secondary
        }
    }

    private var label: String {
        switch state {
        case .active: return "Active"
        case .scheduled: return "Scheduled"
        case .inactive: return "Off"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SabbathStatusBadge(state: .active)
        SabbathStatusBadge(state: .scheduled)
        SabbathStatusBadge(state: .inactive)
    }
}
