import SwiftUI

struct InputTypeView: View {
    var initialValue: Any?
    let input: InputType
    let config: [String: Any]?
    let completion: (Any?) -> Void

    var body: some View {
        inputTypeView
    }

    @ViewBuilder
    private var inputTypeView: some View {
        switch input {
        case .slider:
            SliderInputType(
                config: config,
                completion: completion,
                initialValue: initialValue
            )
        case .text:
            TextInputType(
                config: config,
                completion: completion,
                initialValue: initialValue)
        case .form:
            FormInputType(
                config: config,
                completion: completion,
                initialValue: initialValue)
        case .time:
            TimeInputType(
                config: config,
                completion: completion,
                initialValue: initialValue)
        case .rating:
            RatingInputType(
                config: config,
                completion: completion,
                initialValue: initialValue)
        }
    }
}

#Preview {
    ScrollView {
        ForEach(InputType.allCases, id: \.self) { input in
            InputTypeView(input: input, config: nil, completion: { value in })
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding()
        }
    }
}
