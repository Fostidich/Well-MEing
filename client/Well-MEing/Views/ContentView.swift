import SwiftUI

struct ContentView: View {
    @State private var currentPage: String = "dashboard"

    var body: some View {
        MainPage(name: currentPage, currentPage: $currentPage)
            .background(Color.black)
    }
}

#Preview {
    ContentView()
}
