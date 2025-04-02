import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State var currentPage: String = "dashboard"  
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        if authViewModel.user == nil {
            LoginView(authViewModel: authViewModel) 
        } else {
            mainView
                .onAppear {
                    fetchUserData()
                }
        }
    }

    var mainView: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.frame(in: .global).origin.y) { _, newValue in
                        scrollOffset = -newValue + 50
                    }
            }
            .frame(height: 0)

            Spacer().frame(height: 50)

            Text(currentPage.capitalized)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
                .opacity(CGFloat(max(0, 1 - scrollOffset / 24)))
                .padding()

            contentView

            Spacer().frame(height: 100)
        }
        .overlay(
            Frame(scrollOffset: $scrollOffset, currentPage: $currentPage)
        )
    }

    @ViewBuilder
    private var contentView: some View {
        switch currentPage {
        case "dashboard": Dashboard()
        case "calendar": Calendar()
        case "assistant": Assistant()
        case "progress": Progress()
        case "profile": Profile(authViewModel: authViewModel)
        default: EmptyView()
        }
    }
}

#Preview {
    ContentView(currentPage: "profile").mainView
}
