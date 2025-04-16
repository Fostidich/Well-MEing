import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: Authentication
    @State var currentPage: String = "dashboard"
    @State private var scrollOffset: CGFloat = 0

    /// If the user has not log in yet, the log in page is shown, otherwise the main view of the application
    /// with its main content in shown.
    var body: some View {
        if auth.user == nil {
            LoginView(auth: auth)
        } else {
            mainView.onAppear(perform: {
                UserCache.shared.fetchUserData()
            })
        }
    }

    /// The main view of the application (the one shown after log in) consists of a scroll view which each
    /// section page can customize as it'd like.
    /// A frame (footer buttons, section title and header) is overlaid over the main scroll view, and works
    /// independently from any section page content.
    /// Each section page can thus only work within the scroll view established "below" the main frame.
    var mainView: some View {
        ScrollView {
            // Observe the scrolling distance in order to edit the opacity of some elements accordingly
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.frame(in: .global).origin.y) {
                        _, newValue in
                        scrollOffset = -newValue + 50
                    }
            }
            .frame(height: 0)

            Spacer().frame(height: 50)

            // Title of the current section page (below the frame)
            Text(currentPage.capitalized)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
                .opacity(CGFloat(max(0, 1 - scrollOffset / 24)))
                .padding()

            // Place the main section page content
            contentView

            Spacer().frame(height: 100)
        }
        .overlay(
            // Place the frame (footer and header) in the foreground
            Frame(scrollOffset: $scrollOffset, currentPage: $currentPage)
        )
    }

    /// The section page content is chosen based on the name of the current page.
    /// This name is stored in a variable which is updated when a button in the footer of the frame
    /// is tapped.
    @ViewBuilder
    private var contentView: some View {
        switch currentPage {
        case "dashboard": Dashboard()
        case "assistant": Assistant()
        case "progress": Progress()
        default: EmptyView()
        }
    }

    /// Upon request, user data is updated by making a new fetch.
    func refreshScroll() {
        // TODO: implement this effect
        UserCache.shared.fetchUserData()
    }

}

#Preview {
    print(Date())
    let mockAuth = Authentication()
    let dummyUser = unsafeBitCast(NSMutableDictionary(), to: User.self)
    mockAuth.user = dummyUser
    UserDefaults.standard.set("publicData", forKey: "userUID")
    return ContentView().environmentObject(mockAuth)
}
