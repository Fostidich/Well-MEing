import SwiftUI

struct InputTypeView: View {
    let metric: Metric
    @Binding var data: Submission
    let updateView: () -> Void

    init(
        metric: Metric,
        data: Binding<Submission>,
        updateView: @escaping () -> Void
    ) {
        self.metric = metric
        self._data = data
        self.updateView = updateView

        self.data.metrics = self.data.metrics ?? [:]
    }

    var body: some View {
        inputTypeView
    }

    @ViewBuilder
    private var inputTypeView: some View {
        switch metric.input {
        case .slider:
            SliderInputType(config: metric.config) { value in
                data.metrics?[metric.name] = value
                updateView()
            }
        case .text:
            TextInputType { value in
                let emptyValue =
                    (value as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
                // Update metric value if non-empty
                data.metrics?[metric.name] = emptyValue ? nil : value
                updateView()
            }
        case .form:
            Text("Form")
        case .time:
            Text("Time")
        case .rating:
            Text("Rating")
        }
    }

}
