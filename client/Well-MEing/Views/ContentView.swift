import SwiftUI

struct ContentView: View {
    @State private var currentPage: String = "dashboard"
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            // Find how much the user has scrolled
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.frame(in: .global).origin.y) {
                        _, newValue in
                        scrollOffset = -newValue + 64 // directly update top offset
                    }
            }
            .frame(height: 0)

            // Insert the content of one of the main pages
            contentView

            // Offset the bottom so user can scroll until the end
            Spacer().frame(height: 100)
        }
        .overlay(
            // Place the footer/header frame above page content
            Frame(scrollOffset: $scrollOffset, currentPage: $currentPage)
        )
        .background(Color.black)
    }

    // Choose main page content based on current page variable
    @ViewBuilder
    private var contentView: some View {
        switch currentPage {
        case "dashboard": Dashboard(scrollOffset: $scrollOffset)
        case "calendar": Calendar()
        case "assistant": Assistant()
        case "progress": Progress()
        case "profile": Profile()
        default: EmptyView()
        }
    }
}

#Preview {
    ContentView()
}
