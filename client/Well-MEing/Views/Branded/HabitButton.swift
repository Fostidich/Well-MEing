import SwiftUI

struct HabitButton: View {
    let habit: Habit
    @State private var showModal = false
    var showDeleteAlert: Binding<Bool>?
    var deleteSuccess: Binding<Bool>?

    var body: some View {
        Button(action: { showModal.toggle() }) {
            HabitButtonContent(habit: habit)
        }
        .contextMenu {
            // Show delete button on long press
            Button(role: .destructive) {
                DispatchQueue.main.async {
                    deleteSuccess?.wrappedValue = HabitManager.deleteHabit(
                        habitName: habit.name)
                    showDeleteAlert?.wrappedValue = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showModal) {
            Modal(title: "Log an habit") {
                HabitLoggingModalContent(habit: habit)
            }
        }
        .sensoryFeedback(
            .impact(weight: .heavy),
            trigger: showDeleteAlert?.wrappedValue
        )
        .sensoryFeedback(.impact(weight: .heavy), trigger: showModal)
    }

}

struct HabitButtonContent: View {
    let habit: Habit

    // TODO: add description and limit lines number
    var body: some View {
        ZStack {
            // Button color fill
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))

            // Content of the button
            VStack {
                // Show habit name and symbol, and submissions count
                HStack {
                    Image(systemName: "flame")
                    Text(habit.name)
                        .bold()
                        .foregroundColor(.accentColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(String(habit.submissionsCount))
                        .bold()
                        .foregroundColor(.accentColor)
                }

                Spacer().frame(height: 15)

                // Show goal text with symbol, if set
                if let goal = habit.goal {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")

                        Text(goal)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .frame(
                                maxWidth: .infinity, alignment: .leading
                            )
                            .foregroundColor(.secondary)
                    }
                    Spacer().frame(height: 15)
                }

                // Show last submission date, if present
                if let last = habit.lastSubmissionDate?.fancyString {
                    HStack {
                        Spacer()
                        Text("Last")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.accentColor)
                        Text(last)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}
