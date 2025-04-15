import SwiftUI

struct HabitModalContent: View {
    let habit: Habit
    @State var data: Submission = Submission()

    var body: some View {
        HabitIntroView(habit: habit)
        Divider().padding(.vertical)
        HabitDetailsView(data: $data)
        Divider().padding(.vertical)
        HabitMetricView(habit: habit, data: $data)
    }
}

struct HabitIntroView: View {
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

struct HabitDetailsView: View {
    @State private var timestamp = Date()
    @State private var notes = ""
    @Binding var data: Submission

    var body: some View {
        // Timestamp selector
        DatePicker("Time", selection: $timestamp, in: ...Date())
            .bold()
            .foregroundColor(.accentColor)
            .datePickerStyle(.compact)
            .onChange(of: timestamp) { _, newValue in
                data.timestamp = newValue
            }

        // Text field for optional notes
        ZStack(alignment: .topLeading) {
            TextInput(text: $notes)
                .font(.callout)
                .frame(minHeight: 100)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
            
            if notes.isEmpty {
                Text("Add notes...")
                    .foregroundColor(.gray)
                    .font(.callout)
                    .padding(12)
            }
        }
        .onChange(of: notes) { _, newValue in
            data.notes = newValue.trimmingCharacters(
                in: .whitespacesAndNewlines)
        }
    }
}

struct HabitMetricView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    @State private var filledIn: Bool = false
    @Binding var data: Submission
    @State private var showError = false
    @State private var tapped = false

    var body: some View {
        // List all metrics under metrics title
        Text("Metrics")
            .font(.title2)
            .bold()
            .padding(.bottom)
            .foregroundColor(.accentColor)

        ForEach(habit.metrics ?? []) { metric in
            MetricView(metric: metric) { value in
                // This closure is executed each time a metric is inserted
                data.metrics = data.metrics ?? [:]
                data.metrics?[metric.name] = value
            }
            .onAppear {
                filledIn =
                    (data.metrics?.count ?? 0) == (habit.metrics?.count ?? 0)
            }
        }

        // Tell user to fill all fields
        if !filledIn {
            Text("Fill in all fields to log")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top)
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
                let success = HabitManager.recordSubmission(habit: habit.name, submission: data)
                if success {
                    dismiss()
                } else {
                    showError = true
                }
                tapped = false
            }
        }
        .padding(filledIn ? .vertical : .bottom)
        .disabled(!filledIn || tapped)
        .onAppear {
            filledIn = (data.metrics?.count ?? 0) == (habit.metrics?.count ?? 0)
        }
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
                name: "Metric name",
                description: "Metric description",
                input: InputType.slider,
                config: [
                    "type": "int",
                    "min": 10,
                    "max": 50,
                ]
            ),
            Metric(
                name: "Metric name 3",
                description: "Metric description",
                input: InputType.slider
            ),
            Metric(
                name: "Metric name 2",
                description: "Metric description 2",
                input: InputType.slider
            ),
        ],
        history: nil
    )
    return Modal(title: "Log an habit") {
        HabitModalContent(habit: habit)
    }
}
