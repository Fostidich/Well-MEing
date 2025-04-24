import SwiftUI

struct HButton: View {
    var text: String = String(describing: Self.self)
    var textColor: Color = .primary
    var backgroundColor: Color = .secondary.opacity(0.20)
    var action: () -> Void = { print("Tapped HButton") }

    var body: some View {
        Button(action: {
            action()
        }) {
            // Content of the task button
            Text(text)
                .bold()
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    // Button color fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(backgroundColor)
                }
        }
        .buttonStyle(.plain)
    }
}
