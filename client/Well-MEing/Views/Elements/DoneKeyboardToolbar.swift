import SwiftUI

struct DoneKeyboardToolbar<Content: View>: View {
    @FocusState private var isKeyboardFocused: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            content
                .focused($isKeyboardFocused)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isKeyboardFocused = false
                }
            }
        }
    }
}
