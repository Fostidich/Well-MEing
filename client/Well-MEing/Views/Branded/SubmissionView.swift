import SwiftUI

struct SubmissionView: View {
    var showDeleteAlert: Binding<Bool>?
    var deleteSuccess: Binding<Bool>?
    let habitName: String
    let metricTypes: [String: InputType]
    let submission: Submission

    var body: some View {
        // Place submission block with content
        SubmissionButtonContent(
            habitName: habitName,
            metricTypes: metricTypes,
            submission: submission
        )
        .contextMenu {
            // Show delete button on long press
            Button(role: .destructive) {
                DispatchQueue.main.async {
                    if let id = submission.id {
                        deleteSuccess?.wrappedValue = HabitManager
                            .deleteSubmission(
                            habitName: habitName, id: id)
                    } else {
                        deleteSuccess?.wrappedValue = false
                    }
                    showDeleteAlert?.wrappedValue = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

}

struct SubmissionButtonContent: View {
    enum Split {
        case odd, even
    }

    let habitName: String
    let metricTypes: [String: InputType]
    let submission: Submission

    var body: some View {
        VStack(alignment: .leading) {
            // Show habit name and submission time
            HStack {
                Text(habitName)
                    .bold()
                    .font(.title3)
                    .foregroundColor(.accentColor)
                Spacer()
                Text(submission.timestamp.timeString)
                    .foregroundColor(.secondary)
            }

            // Show notes if present
            if let notes = submission.notes {
                Text(notes)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .frame(
                        maxWidth: .infinity, alignment: .leading
                    )
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }

            // List metrics values (even and odd indexed on different columns)
            HStack(alignment: .top) {
                VStack {
                    metricsColumn(.even)
                }
                VStack {
                    metricsColumn(.odd)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.2))
        }
    }

    func metricsColumn(_ split: Split) -> some View {
        // Sort metrics, and select odd/even indexes
        let filteredMetrics =
            submission.metrics?
            .sorted { $0.key < $1.key }
            .enumerated()
            .filter { $0.offset % 2 == (split == .even ? 0 : 1) }
            .map { $0.element }
            ?? []

        // Return the for each view
        return ForEach(
            filteredMetrics,
            id: \.key
        ) { metric, value in
            if let input = metricTypes[metric] {
                MetricDisplayByInputType(
                    metric: metric, value: value, input: input
                )
            }
        }
    }

}

struct MetricDisplayByInputType: View {
    let metric: String
    let value: Any
    let input: InputType

    var body: some View {
        VStack(alignment: .leading) {
            // Metric name
            Text(metric)
                .font(.subheadline)
                .bold()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Metric value display based on input type
            metricValue
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.2))
        }
    }

    @ViewBuilder
    private var metricValue: some View {
        switch input {
        case .slider:
            Text("\(value)")
                .font(.callout)
        case .text:
            Text("\(value)")
                .font(.caption)
        case .form:
            if let value = value as? String, !value.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(
                        value.split(separator: ";").map {
                            String($0)
                        }, id: \.self
                    ) { field in
                        HStack {
                            Image(systemName: "checkmark.square")
                                .foregroundColor(.accentColor)
                            Text(field)
                        }
                        .font(.callout)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "square")
                        .foregroundColor(.accentColor)
                    Text("N/A")
                }
                .font(.callout)
            }
        case .time:
            Text("\(value)")
                .font(.callout)
        case .rating:
            HStack {
                ForEach(1...(value as? Int ?? 0), id: \.self) { i in
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

}
