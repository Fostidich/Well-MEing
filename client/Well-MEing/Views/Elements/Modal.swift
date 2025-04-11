import SwiftUI

struct Modal<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let content: Content

    init(title: String = "", @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                content
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .frame(
                maxWidth: .infinity, maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
        }
    }
}
