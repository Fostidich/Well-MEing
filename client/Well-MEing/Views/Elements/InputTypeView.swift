import SwiftUI

struct InputTypeView: View {
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
            SliderInputType(config: config, completion: completion)
        case .text:
            TextInputType(completion: completion)
        case .form:
            Text("Form")
        case .time:
            Text("Time")
        case .rating:
            Text("Rating")
        }
    }
}


