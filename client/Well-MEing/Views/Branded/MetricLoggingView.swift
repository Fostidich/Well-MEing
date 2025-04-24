import SwiftUI

struct MetricLoggingView: View {
    var initialValue: Any?
    let metric: Metric
    let completion: (Any?) -> Void

    var body: some View {
        VStack {
            // Metric name title
            Text(metric.name)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .padding(.top)
                .padding(.horizontal)

            // Show metric description
            if let description = metric.description {
                Text(description)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }

            // Input selector by type
            InputTypeView(
                initialValue: initialValue,
                input: metric.input,
                config: metric.config,
                completion: completion
            )
            .padding()
        }
        .background(
            // Button color fill
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
        )
    }
}
