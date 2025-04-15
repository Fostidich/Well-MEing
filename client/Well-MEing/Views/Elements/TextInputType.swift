import SwiftUI

struct TextInputType: View {
    let completion: (Any?) -> Void
    @State var text: String = ""

    var body: some View {
        ZStack(alignment: .topLeading) {
            WritingBlock(text: $text)
                .font(.callout)
                .frame(minHeight: 50)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )

            if text.isEmpty {
                Text("Write metric...")
                    .foregroundColor(.gray)
                    .font(.callout)
                    .padding(12)
            }
        }
        .onChange(of: text) { _, newValue in
            let emptyValue =
                newValue
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty

            // Update metric value if non-empty
            completion(emptyValue ? nil : newValue)
        }
    }
}
