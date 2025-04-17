import SwiftUI

struct Modal<Content: View>: View {
    enum DismissButton {
        case cancel
        case done
        case cancelAndDone
    }

    @Environment(\.dismiss) var dismiss
    let title: String
    let content: Content
    let dismissButton: DismissButton
    let completion: (() -> Void)?

    init(
        title: String = "",
        dismissButton: DismissButton = .cancel,
        completion: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.dismissButton = dismissButton
        self.completion = completion
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                DoneKeyboardToolbar {
                    VStack(alignment: .leading) {
                        content
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if dismissButton == .cancel
                    || dismissButton == .cancelAndDone
                {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                if dismissButton == .done
                    || dismissButton == .cancelAndDone
                {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            if let completion = completion {
                                completion()
                            }
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
