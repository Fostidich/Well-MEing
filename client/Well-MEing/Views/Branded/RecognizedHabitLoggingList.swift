import SwiftUI

struct RecognizedHabitLoggingList: View {
    @State private var selectedSubmission: Submission?
    @State private var selectedHabit: Habit?
    @State private var ignored: [String] = []
    @Binding var actions: Actions?

    var body: some View {
        if let loggings = actions?.loggings {
            Text("Log your habits")
                .bold()
                .padding(.top)
                .font(.title3)

            ForEach(loggings.map { ($0.key, $0.value) }, id: \.0) {
                habitName, submissions in

                // Don't show submissions with no habit to record to
                let habitFound = UserCache.shared.habits?
                    .first(where: { $0.name == habitName })

                ForEach(submissions) {
                    submission in

                    Button(action: {
                        selectedHabit = habitFound
                        selectedSubmission = submission
                    }) {
                        RecognizedHabitLoggingButtonContent(
                            habitName: habitName, submission: submission
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        // Show delete button on long press
                        Button(role: .destructive) {
                            ignored.append(submission.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .disabled(
                        habitFound == nil || ignored.contains(submission.id)
                    )
                    .sheet(item: $selectedSubmission) { submission in
                        Modal(title: "Log habit") {
                            if let habit = selectedHabit {
                                HabitLoggingModalContent(
                                    submission: selectedSubmission,
                                    habit: habit
                                ) {
                                    ignored.append(submission.id)
                                }
                            }
                        }
                    }
                }
            }
            .sensoryFeedback(
                .impact(weight: .heavy), trigger: selectedSubmission?.id)
        }
    }

}

struct RecognizedHabitLoggingButtonContent: View {
    let habitName: String
    let submission: Submission

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Show habit name
                Text(habitName)
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.leading)
                    .bold()

                Spacer()

                // Show timestamp
                Text(submission.timestamp.fancyString)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }

            // Show notes
            if let notes = submission.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.primary)
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
