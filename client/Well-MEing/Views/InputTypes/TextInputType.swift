import SwiftUI

struct TextInputType: View {
    let completion: (Any?) -> Void
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 4) {
            TextField("Write metric...", text: $text)
                .multilineTextAlignment(.leading)
                .onChange(of: text) { _, newValue in
                    // Update metric value if non-empty
                    completion(newValue.clean.map { String($0.prefix(500)) })
                }
            Divider()
        }
    }
}
