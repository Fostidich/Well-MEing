import SwiftUI

struct InputSelectorView: View {
    let input: InputType
    @Binding var config: [String: Any]
    var resetTrigger: Bool?

    var body: some View {
        // Show input type name and view
        ScrollView {
            Text(input.rawValue.capitalized)
                .foregroundColor(.accentColor)
                .padding()
            inputTypeSelector
        }
        .scrollDismissesKeyboard(.immediately)
        .padding()
        .frame(width: 300)
    }

    @ViewBuilder
    private var inputTypeSelector: some View {
        switch input {
        case .slider:
            SliderInputSelector(config: $config, resetTrigger: resetTrigger)
        case .text:
            TextInputSelector(config: $config, resetTrigger: resetTrigger)
        case .form:
            FormInputSelector(config: $config, resetTrigger: resetTrigger)
        case .time:
            TimeInputSelector(config: $config, resetTrigger: resetTrigger)
        case .rating:
            RatingInputSelector(config: $config, resetTrigger: resetTrigger)
        }
    }
}

#Preview {
    @Previewable @State var config: [String: Any] = [:]
    ScrollView {
        ForEach(InputType.allCases, id: \.self) { input in
            InputSelectorView(input: input, config: $config)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding()
        }
    }
}
