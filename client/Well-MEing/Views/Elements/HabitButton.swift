import SwiftUI

struct HabitButton: View {
    let habit: Habit
    @State private var showModal = false

    var body: some View {
        Button(action: { showModal.toggle() }) {
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.primary.opacity(0.80))
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
            .padding(.horizontal)
            .sheet(isPresented: $showModal) {
                // Open the habit logging modal
                Modal(title: "Log an habit") {
                    HabitModalContent(habit: habit)
                }
            }
        }
    }
}
