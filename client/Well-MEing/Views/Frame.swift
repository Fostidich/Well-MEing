import SwiftUI

struct Frame: View {
    @Binding var scrollOffset: CGFloat
    @Binding var currentPage: String

    var body: some View {
        VStack {
            // Header with gradual opacity increased with user scrolling
            Text(currentPage.capitalized)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .opacity(CGFloat(max(0, scrollOffset / 64)))  // set vanishing rapidity
                .foregroundColor(
                    .white.opacity(CGFloat(max(0, scrollOffset / 64)))  // set vanishing rapidity
                )

            Spacer()

            // Footer with main buttons for each main page
            HStack {
                BottomBarButton(
                    icon: "square.split.2x2.fill", destination: "dashboard",
                    currentPage: $currentPage)
                BottomBarButton(
                    icon: "calendar.circle.fill", destination: "calendar",
                    currentPage: $currentPage)
                BottomBarButton(
                    icon: "waveform.circle.fill", destination: "assistant",
                    currentPage: $currentPage)
                BottomBarButton(
                    icon: "tray.full.fill", destination: "progress",
                    currentPage: $currentPage)
                BottomBarButton(
                    icon: "person.fill", destination: "profile",
                    currentPage: $currentPage)
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
        // Tapping the button re-renders the current page state
        Button {
            currentPage = destination
        } label: {
            Image(systemName: icon)
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
