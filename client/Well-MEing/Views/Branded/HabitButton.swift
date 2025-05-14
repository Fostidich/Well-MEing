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
                Task {
                    deleteSuccess?.wrappedValue = await Request.deleteHabit(
                        habitName: habit.name).call()
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

    var body: some View {
        // Content of the button
        VStack(spacing: 8) {
            // Show habit name and submissions count
            HStack {
                Text(habit.name)
                    .bold()
                    .lineLimit(2)
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(String(habit.submissionsCount))
                    .bold()
                    .foregroundColor(.accentColor)
            }

            // Show description text with symbol, if set
            if let description = habit.description {
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                        .padding(.leading, 8)
                        .padding(.trailing, 4)

                    Text(description)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(
                            maxWidth: .infinity, alignment: .leading
                        )
                        .foregroundColor(.secondary)
                }
            }

            // Show goal text with symbol, if set
            if let goal = habit.goal {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                        .padding(.leading, 8)
                        .padding(.trailing, 4)

                    Text(goal)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(
                            maxWidth: .infinity, alignment: .leading
                        )
                        .foregroundColor(.secondary)
                }
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
        .background {
            // Button color fill
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
        }
    }
}
