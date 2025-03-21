import SwiftUI

struct MainPage: View {
    var name: String
    @Binding var currentPage: String

    var body: some View {
        ZStack {
            switch name {
            case "dashboard":
                DashboardPage()
            case "calendar":
                CalendarPage()
            case "assistant":
                AssistantPage()
            case "progress":
                ProgressPage()
            case "profile":
                ProfilePage()
            default:
                EmptyView()
            }

            Spacer()
            Frame(name: name.capitalize, currentPage: $currentPage)
        }
    }
}

struct Frame: View {
    var name: String
    @Binding var currentPage: String

    var body: some View {
        VStack {
            Text(name)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            HStack {
                BottomBarButton(icon: "square.split.2x2.fill", destination: "dashboard", currentPage: $currentPage)
                BottomBarButton(icon: "calendar.circle.fill", destination: "calendar", currentPage: $currentPage)
                BottomBarButton(icon: "waveform.circle.fill", destination: "assistant", currentPage: $currentPage)
                BottomBarButton(icon: "tray.full.fill", destination: "progress", currentPage: $currentPage)
                BottomBarButton(icon: "person.fill", destination: "profile", currentPage: $currentPage)
            }
            .frame(height: 75)
            .background(.ultraThinMaterial)
        }
    }
}

struct BottomBarButton: View {
    let icon: String
    let destination: String
    @Binding var currentPage: String

    var body: some View {
        Button {
            currentPage = destination
        } label: {
            Image(systemName: icon)
                .resizable()
                .frame(width: 26, height: 26)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
