import SwiftUI

struct TextInputType: View {
    let config: [String: Any]?
    let completion: (Any?) -> Void
    var initialValue: Any?
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 4) {
            TextField("Write metric...", text: $text)
                .submitLabel(.done)
                .multilineTextAlignment(.leading)
                .onChange(of: text) { _, newValue in
                    // Update metric value if non-empty
                    completion(newValue.clean.map { String($0.prefix(500)) })
                }
            Divider()
        }
        .onAppear {
            text = initialValue as? String ?? ""
        }
    }
}
