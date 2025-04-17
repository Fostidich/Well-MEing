import SwiftUI

struct HabitLoggingModalContent: View {
    let habit: Habit
    @StateObject var data: Submission = Submission()

    var body: some View {
        LoggingIntroView(habit: habit)
        Divider().padding(.vertical)
        LoggingDetailsView(data: data)
        Divider().padding(.vertical)
        if (habit.metrics?.count ?? 0) > 0 {
            LoggingMetricView(habit: habit, data: data)
            Divider().padding(.vertical)
        }
        LoggingLogView(habit: habit, data: data)
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
    @State private var timestamp = Date()
    @State private var notes = ""
    @ObservedObject var data: Submission

    var body: some View {
        // Timestamp selector
        DatePicker("Details", selection: $timestamp, in: ...Date())
            .bold()
            .font(.title2)
            .foregroundColor(.accentColor)
            .datePickerStyle(.compact)
            .onChange(of: timestamp) { _, newValue in
                data.timestamp = newValue
            }

        // Text field for optional notes
        TextField("Add notes...", text: $notes)
            .padding()
            .multilineTextAlignment(.leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.2))
            )
            .onChange(of: notes) { _, newValue in
                data.notes = newValue.clean.map { String($0.prefix(500)) }
            }
    }
}

struct LoggingMetricView: View {
    let habit: Habit
    @ObservedObject var data: Submission

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
            MetricView(metric: metric) { value in
                // This closure is executed each time a metric is inserted
                data.metrics = data.metrics ?? [:]
                if let value = value {
                    data.metrics?[metric.name] = value
                } else {
                    data.metrics?.removeValue(forKey: metric.name)
                }
            }
        }
    }
}

struct LoggingLogView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    @State private var showError = false
    @State private var tapped = false
    @ObservedObject var data: Submission

    var filledIn: Bool {
        (data.metrics?.count ?? 0) == (habit.metrics?.count ?? 0)
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
            text: "Log",
            textColor: Color(UIColor.systemBackground),
            backgroundColor: (filledIn && !tapped) ? .accentColor : .secondary
        ) {
            tapped = true

            // Defer action to next runloop so UI can update first
            DispatchQueue.main.async {
                let success = HabitManager.recordSubmission(
                    habit: habit.name, submission: data)
                if success { dismiss() } else { showError = true }
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
    let habit = Habit(
        name: "Habit name test",
        description: "Description test",
        goal: "Goal test",
        metrics: [
            Metric(
                name: "Sport",
                description: "Metric description",
                input: InputType.slider
            ),
            Metric(
                name: "Cooking",
                description: "Metric description",
                input: InputType.text
            ),
            Metric(
                name: "Sleep",
                description: "Metric description",
                input: InputType.form
            ),
            Metric(
                name: "Food",
                description: "Metric description",
                input: InputType.rating
            ),
            Metric(
                name: "Drink",
                description: "Metric description",
                input: InputType.time
            ),
        ],
        history: nil
    )
    return Modal(title: "Log an habit") {
        HabitLoggingModalContent(habit: habit)
    }
}
