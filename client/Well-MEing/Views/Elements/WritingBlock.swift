import SwiftUI

struct WritingBlock: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)

        // Add toolbar with "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: textView, action: #selector(textView.resignFirstResponder))
        toolbar.items = [UIBarButtonItem.flexibleSpace(), doneButton]
        textView.inputAccessoryView = toolbar
        
        // Enable setting the text box backgound to transparent
        textView.backgroundColor = .clear
        textView.isOpaque = false
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: WritingBlock

        init(_ parent: WritingBlock) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
