import SwiftUI

struct RecognizedHabitCreationList: View {
    @State private var selectedHabit: Habit?
    @State private var ignored: [String] = []
    @Binding var actions: Actions?

    var body: some View {
        if let habits = actions?.creations {
            Text("Create new habits")
                .bold()
                .padding(.top)
                .font(.title3)

            ForEach(habits) { habit in
                // Disable habit when it already exist
                let habitFound = UserCache.shared.habits?
                    .first(where: { $0.name == habit.name })

                Button(action: {
                    selectedHabit = habit
                }) {
                    RecognizedHabitCreationButtonContent(habit: habit)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    // Show delete button on long press
                    Button(role: .destructive) {
                        ignored.append(habit.name)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .disabled(habitFound != nil || ignored.contains(habit.name))
                .sheet(item: $selectedHabit) { _ in
                    Modal(title: "Create habit") {
                        HabitCreationModalContent(habit: selectedHabit)
                    }
                }
            }
            .sensoryFeedback(
                .impact(weight: .heavy), trigger: selectedHabit?.id)
        }
    }

}

struct RecognizedHabitCreationButtonContent: View {
    let habit: Habit

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Show name
                Text(habit.name)
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.leading)
                    .bold()

                Spacer()

                // Show metrics count
                Text("\(habit.metrics?.count ?? 0) metrics")
                    .foregroundColor(.secondary)
                    .font(.callout)
            }

            // Show description
            if let description = habit.description {
                Text(description)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            // Show goal
            if let goal = habit.goal {
                Text(goal)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background {
            // Button color fill
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
    }
}
