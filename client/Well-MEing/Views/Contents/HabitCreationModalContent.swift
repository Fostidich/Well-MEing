import SwiftUI

struct HabitCreationModalContent: View {
    var habit: Habit?
    @State private var name: String =
        "New habit \((UserCache.shared.habits?.count ?? 0) + 1)"
    @State private var description: String = ""
    @State private var goal: String = ""
    @State private var metrics: [[String: Any]] = []

    var body: some View {
        VStack(alignment: .leading) {
            CreationIntroView(
                name: $name, description: $description, goal: $goal)
            CreationMetricsView(metrics: $metrics)
            CreationCreateView(
                name: $name,
                description: $description,
                goal: $goal,
                metrics: $metrics
            )
        }
        .onAppear {
            if let habit = habit {
                name = habit.name
                description = habit.description ?? ""
                goal = habit.goal ?? ""
                metrics = habit.metrics?.map { $0.asDict } ?? []
            }
        }
    }
}

struct CreationIntroView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var goal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Habit name", text: $name)
                .submitLabel(.done)
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
                .submitLabel(.done)
            Divider()
                .padding(.bottom)

            Text("Goal")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)

            TextField("Set a goal", text: $goal)
                .submitLabel(.done)
            Divider()
                .padding(.bottom)
        }
    }
}

struct CreationMetricsView: View {
    @Binding var metrics: [[String: Any]]

    var body: some View {
        // Metrics section title
        Text("Metrics")
            .font(.title)
            .bold()
            .padding(.bottom)
            .foregroundColor(.accentColor)

        // List metrics
        ForEach(metrics.indices, id: \.self) { index in
            MetricCreationView(metric: $metrics[index])
        }

        // Add metric button
        Button(action: {
            metrics.append(["name": "New metric \(metrics.count + 1)"])
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
        .disabled(metrics.count >= 10)
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
    @Binding var metrics: [[String: Any]]

    var filledIn: Bool {
        return !name.isWhite
            && (UserCache.shared.habits ?? []).allSatisfy { $0.name != name }
            && metrics.allSatisfy {
                !($0["name"] as? String).isWhite
            }
            && Set(
                metrics.compactMap {
                    ($0["name"] as? String)?.clean
                }
            ).count == metrics.count
    }

    var body: some View {
        // Tell user to fill all fields
        if !filledIn {
            Text("Habit or metrics name are missing or already in use")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
                .foregroundColor(.red)
        }

        // Submit button
        HButton(
            text: "Create",
            textColor: Color(.systemBackground),
            backgroundColor: (filledIn && !tapped) ? .accentColor : .secondary
        ) {
            tapped = true
            guard
                let habit = Habit(
                    name: name,
                    description: description,
                    goal: goal,
                    metrics: metrics.compactMap {
                        Metric(
                            name: $0["name"] as? String ?? "",
                            description: $0["description"] as? String,
                            input: $0["input"] as? InputType ?? .slider,
                            config: $0["config"] as? [String: Any]
                        )
                    }
                )
            else {
                showError = true
                tapped = false
                return
            }

            // Defer action to next runloop so UI can update first
            Task {
                let (success, _) = await Request.createHabit(habit: habit)
                    .call()
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
