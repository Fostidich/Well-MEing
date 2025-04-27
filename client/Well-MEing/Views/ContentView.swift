import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: Authentication
    @State var currentPage: SectionPage = .dashboard
    @State private var scrollOffset: CGFloat = 0
    @State private var refreshTrigger = false

    /// If the user has not log in yet, the log in page is shown, otherwise the main view of the application
    /// with its main content in shown.
    var body: some View {
        if auth.user == nil {
            LoginView(auth: auth)
        } else {
            mainView.onAppear(perform: refresh)
        }
    }

    /// The main view of the application (the one shown after log in) consists of a scroll view which each
    /// section page can customize as it'd like.
    /// A frame (footer buttons, section title and header) is overlaid over the main scroll view, and works
    /// independently from any section page content.
    /// Each section page can thus only work within the scroll view established "below" the main frame.
    var mainView: some View {
        NavigationStack {
            ScrollView {
                // Observe the scrolling distance in order to edit the opacity of some elements accordingly
                GeometryReader { geometry in
                    Color.clear
                        .onChange(
                            of: geometry.frame(in: .named("scroll")).origin.y
                        ) {
                            _, newValue in
                            scrollOffset = -newValue

                            if scrollOffset < -150 && !refreshTrigger {
                                // Activate scroll refresh
                                refreshTrigger = true
                            } else if scrollOffset >= 0 && refreshTrigger {
                                // Reset trigger once scrolled back up
                                Task(operation: refresh)
                                Thread.sleep(forTimeInterval: 1)
                                refreshTrigger = false
                            }
                        }
                }
                .frame(height: 0)

                // Show refresh animation when scrolling over the top
                ZStack {
                    if refreshTrigger {
                        ProgressView()
                    } else if scrollOffset <= 0 {
                        Image(systemName: "arrow.clockwise")
                            .bold()
                            .font(.title3)
                            .offset(y: -2)
                            .foregroundColor(.accentColor)
                            .padding()
                            .background {
                                Circle()
                                    .fill(.secondary.opacity(0.2))
                            }
                            .opacity(-scrollOffset / 100)
                    }
                }
                .frame(height: 50)

                // Title of the current section page (below the frame)
                Text(currentPage.rawValue.capitalized)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                    .opacity(CGFloat(max(0, 1 - scrollOffset / 25)))
                    .padding()

                // Place the main section page content
                contentView

                Spacer().frame(height: 100)
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: refreshTrigger)
            .coordinateSpace(name: "scroll")
            .overlay(
                // Place the frame (footer and header) in the foreground
                Frame(scrollOffset: $scrollOffset, currentPage: $currentPage)
            )
        }
    }

    /// The section page content is chosen based on the name of the current page.
    /// This name is stored in a variable which is updated when a button in the footer of the frame
    /// is tapped.
    @ViewBuilder
    private var contentView: some View {
        switch currentPage {
        case .dashboard: Dashboard()
        case .assistant: Assistant()
        case .progress: Progress()
        }
    }

    /// Upon request, user data is updated by making a new fetch.
    func refresh() {
        UserCache.shared.fetchUserData()
    }

}

#Preview {
    print(Date())
    let mockAuth = Authentication()
    let dummyUser = unsafeBitCast(NSMutableDictionary(), to: User.self)
    mockAuth.user = dummyUser
    UserDefaults.standard.set("publicData", forKey: "userUID")
    return ContentView(currentPage: .assistant).environmentObject(mockAuth)
}
