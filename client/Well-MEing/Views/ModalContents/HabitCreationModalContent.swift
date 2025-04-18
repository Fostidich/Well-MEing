import SwiftUI

struct HabitCreationModalContent: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var goal: String = ""
    @State private var metrics: [Metric] = []

    var body: some View {
        CreationIntroView(name: $name, description: $description, goal: $goal)
        CreationMetricsView(metrics: $metrics)
        CreationCreateView(
            name: $name, description: $description, goal: $goal,
            metrics: $metrics)
    }
}

struct CreationIntroView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var goal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Habit name", text: $name)
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
            Divider()
                .padding(.bottom)

            Text("Description")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)

            TextField("Give a description", text: $description)
            Divider()
                .padding(.bottom)

            Text("Goal")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)

            TextField("Set a goal", text: $goal)
            Divider()
                .padding(.bottom)
        }
    }
}

struct CreationMetricsView: View {
    @Binding var metrics: [Metric]

    var body: some View {
        // Metrics section title
        Text("Metrics")
            .font(.title)
            .bold()
            .padding(.bottom)
            .foregroundColor(.accentColor)

        // List metrics
        ForEach(0..<metrics.count, id: \.self) { index in
            MetricCreationView { value in
                metrics[index] = value
            }
        }

        // Add habit button
        Button(action: {
            if let metric = Metric(name: "New metric \(metrics.count)") {
                metrics.append(metric)
            }
        }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))

                // Button content
                Image(systemName: "plus")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .padding()
            }
        }
        .padding(.bottom)
        .padding(.bottom)
    }
}

struct CreationCreateView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showError = false
    @State private var tapped = false
    @Binding var name: String
    @Binding var description: String
    @Binding var goal: String
    @Binding var metrics: [Metric]
    var filledIn: Bool = false  // TODO: manage this check

    var body: some View {
        // Tell user to fill all fields
        if !filledIn {
            Text("Some fields are missing")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
                .foregroundColor(.red)
        }

        // Submit button
        HButton(
            text: "Create",
            textColor: Color(UIColor.systemBackground),
            backgroundColor: (filledIn && !tapped) ? .accentColor : .secondary
        ) {
            // TODO: when pressing create button, check that names of habit and metrics are not empty
            tapped = true
            guard
                let habit = Habit(
                    name: name,
                    description: description,
                    goal: goal,
                    metrics: metrics
                )
            else {
                return  // TODO: manage this scenario
            }

            // Defer action to next runloop so UI can update first
            DispatchQueue.main.async {
                let success = HabitManager.createHabit(habit: habit)
                if success { dismiss() } else { showError = true }
                tapped = false
            }
        }
        .padding(.bottom)
        .disabled(!filledIn || tapped)
        .alert("Failed to create habit", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    Modal(title: "Create an habit", dismissButton: .cancel) {
        HabitCreationModalContent()
    }
}
