import SwiftUI

struct HabitLoggingModalContent: View {
    let habit: Habit
    let whenCreated: (() -> Void)?
    @State private var timestamp: Date
    @State private var notes: String
    @State private var metrics: [String: Any]

    init(
        submission: Submission? = nil,
        habit: Habit,
        whenCreated: (() -> Void)? = nil
    ) {
        self.habit = habit
        self.whenCreated = whenCreated

        // Initialize values when provided by the recognizer
        if let submission = submission {
            timestamp = submission.timestamp
            notes = submission.notes ?? ""
            metrics = submission.metrics ?? [:]
        } else {
            timestamp = Date()
            notes = ""
            metrics = [:]
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            LoggingIntroView(habit: habit)
            Divider().padding(.vertical)
            LoggingDetailsView(timestamp: $timestamp, notes: $notes)
            Divider().padding(.vertical)
            if (habit.metrics?.count ?? 0) > 0 {
                LoggingMetricsView(habit: habit, metrics: $metrics)
                Divider().padding(.vertical)
            }
            LoggingLogView(
                habit: habit,
                timestamp: $timestamp,
                notes: $notes,
                metrics: $metrics,
                whenCreated: whenCreated
            )
        }
    }

}

struct LoggingIntroView: View {
    let habit: Habit

    var body: some View {
        // Show big habit name
        Text(habit.name)
            .bold()
            .font(.title)
            .foregroundColor(.accentColor)
            .padding(.bottom)

        // Show habit description
        if let description = habit.description {
            Text("Description")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
            Text(description)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
        }

        // Space between description and goal, if both present
        if habit.description != nil && habit.goal != nil {
            Spacer()
                .frame(height: 0)
                .padding(.top)
        }

        // Show habit goal
        if let goal = habit.goal {
            Text("Goal")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
            Text(goal)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
        }
    }
}

struct LoggingDetailsView: View {
    @Binding var timestamp: Date
    @Binding var notes: String

    var body: some View {
        // Timestamp selector
        DatePicker("Details", selection: $timestamp, in: ...Date())
            .bold()
            .font(.title2)
            .foregroundColor(.accentColor)
            .datePickerStyle(.compact)
            .onChange(of: timestamp) { _, newValue in
                timestamp = newValue
            }

        // Text field for optional notes
        TextField("Add notes...", text: $notes)
            .submitLabel(.done)
            .padding()
            .multilineTextAlignment(.leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.2))
            )
            .onChange(of: notes) { _, newValue in
                notes = newValue
            }
    }
}

struct LoggingMetricsView: View {
    let habit: Habit
    @Binding var metrics: [String: Any]

    var body: some View {
        // List all metrics under metrics title
        Text("Metrics")
            .font(.title2)
            .bold()
            .padding(.bottom)
            .foregroundColor(.accentColor)

        ForEach(
            (habit.metrics ?? []).sorted {
                $0.name < $1.name
            }
        ) { metric in
            MetricLoggingView(
                initialValue: metrics[metric.name],
                metric: metric
            ) { value in
                // This closure is executed each time a metric is inserted
                if let value = value {
                    metrics[metric.name] = value
                } else {
                    metrics.removeValue(forKey: metric.name)
                }
            }
        }
    }
}

struct LoggingLogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showError = false
    @State private var tapped = false
    let habit: Habit
    @Binding var timestamp: Date
    @Binding var notes: String
    @Binding var metrics: [String: Any]
    let whenCreated: (() -> Void)?

    var filledIn: Bool {
        metrics.count == (habit.metrics?.count ?? 0)
    }

    var body: some View {
        // Tell user to fill all fields
        if !filledIn {
            Text("Fill in all fields to log")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
                .foregroundColor(.red)
        }

        // Submit button
        HButton(
            text: "Save",
            textColor: Color(.systemBackground),
            backgroundColor: (filledIn && !tapped) ? .accentColor : .secondary
        ) {
            tapped = true
            let submission = Submission(
                timestamp: timestamp,
                notes: notes,
                metrics: metrics
            )

            // Defer action to next runloop so UI can update first
            Task {
                let success = await Request.createSubmission(
                    habitName: habit.name, submission: submission)
                    .call()
                if success {
                    whenCreated?()
                    dismiss()
                } else { showError = true }
                tapped = false
            }
        }
        .padding(.bottom)
        .disabled(!filledIn || tapped)
        .alert("Failed to log submission", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    print(Date())

    let optionalMetrics: [Metric?] = [
        Metric(name: "Sport", description: "desc", input: .slider),
        Metric(name: "Cooking", description: "desc", input: .text),
        Metric(name: "Sleep", description: "desc", input: .form),
        Metric(name: "Food", description: "desc", input: .rating),
        Metric(name: "Drink", description: "desc", input: .time),
    ]

    let metrics: [Metric]? =
        optionalMetrics.compactMap { $0 }.isEmpty
        ? nil : optionalMetrics.compactMap { $0 }

    if let habit = Habit(
        name: "Habit name test",
        description: "Description test",
        goal: "Goal test",
        metrics: metrics,
        history: nil
    ) {
        return Modal(title: "Log an habit") {
            HabitLoggingModalContent(habit: habit)
        }
    } else {
        return Text("Failed to create habit")
    }
}
