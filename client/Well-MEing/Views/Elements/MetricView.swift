import SwiftUI

struct MetricView: View {
    let metric: Metric
    @Binding var data: Submission
    let updateView: () -> Void

    var body: some View {
        VStack {
            // Metric name as title
            Text(metric.name)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .padding(.top)
                .padding(.horizontal)

            // Show metric description if present
            if let description = metric.description {
                Text(description)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }

            // Place the input type correct selector
            InputTypeView(
                metric: metric,
                data: $data,
                updateView: updateView
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
