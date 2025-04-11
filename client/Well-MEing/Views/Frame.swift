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
                .opacity(CGFloat(max(0, scrollOffset / 64)))
                .foregroundColor(
                    .primary.opacity(CGFloat(max(0, scrollOffset / 64)))
                )

            Spacer()

            // Footer with main buttons for each main page
            HStack {
                BottomBarButton(
                    icon: "square.split.2x2.fill", destination: "dashboard",
                    currentPage: $currentPage)
                BottomBarButton(
                    icon: "doc.text.fill", destination: "assistant",
                    currentPage: $currentPage)
                BottomBarButton(
                    icon: "chart.bar.fill", destination: "progress",
                    currentPage: $currentPage)
            }
            .frame(height: 50)
            .background(.ultraThinMaterial)
        }
    }
}

struct BottomBarButton: View {
    let icon: String
    let destination: String
    @Binding var currentPage: String

    var body: some View {
        // Tapping the button re-renders the new current page state
        Button {
            currentPage = destination
        } label: {
            VStack {
                Spacer()
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundColor(
                        currentPage == destination ? .accentColor : .secondary)
                Text(destination.capitalized)
                    .font(.caption2)
                    .foregroundColor(currentPage == destination ? .accentColor : .secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
