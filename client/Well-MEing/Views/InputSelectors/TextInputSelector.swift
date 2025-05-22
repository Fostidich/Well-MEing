import SwiftUI

struct TextInputSelector: View {
    @Binding var config: [String: Any]
    var resetTrigger: Bool?
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 4) {
            TextField("Write metric...", text: $text)
                .submitLabel(.done)
                .multilineTextAlignment(.leading)
            Divider()
        }
        .onAppear(perform: reset)
        .onChange(of: resetTrigger, reset)
    }

    private func reset() {
        text = ""
    }

}
