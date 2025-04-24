import SwiftUI

struct VoiceCommandsPageContent: View {
    @State private var showModal: Bool = false
    @State private var actions:
        (
            habits: [Habit]?,
            submissions: [String: Submission]?
        ) = (nil, nil)

    var body: some View {
        ScrollView {
            // Actions buttons
            VoiceCommandsRecorderBlock(actions: $actions)

            // Show habits found
            if let habits = actions.habits {
                ForEach(habits) { habit in
                    HButton(text: habit.name) {
                        showModal.toggle()
                    }
                    .padding()
                    .sheet(isPresented: $showModal) {
                        Modal(title: "Create habit") {
                            HabitCreationModalContent(
                                name: habit.name,
                                description: habit.description ?? "",
                                goal: habit.goal ?? "",
                                metrics: habit.metrics?.map { $0.asDict } ?? []
                            )
                        }
                    }
                }
            }

            // Show submissions found
            if let submissions = actions.submissions {
                ForEach(submissions.map { ($0.key, $0.value) }, id: \.0) {
                    habitName,
                    submission in
                    if let habit = UserCache.shared.habits?
                        .first(where: { $0.name == habitName })
                    {
                        HabitLoggingModalContent(habit: habit)
                    }
                }
            }
            
            Spacer()
        }
    }

}

#Preview {
    VoiceCommandsPageContent()
}
