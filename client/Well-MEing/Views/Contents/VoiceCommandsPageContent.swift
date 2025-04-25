import SwiftUI

struct VoiceCommandsPageContent: View {
    @State private var actions: Actions? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Actions buttons
                VoiceCommandsRecorderBlock(actions: $actions)

                // Show habits found
                RecognizedHabitCreation(actions: $actions)

                // Show submissions found
                RecognizedHabitLogging(actions: $actions)

                Spacer()
            }
            .padding()
        }
    }

}

struct RecognizedHabitCreation: View {
    @State private var showModal: Bool = false
    @State private var ignored: [String] = []
    @Binding var actions: Actions?

    // TODO: add goal and limit lines number
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
                    showModal.toggle()
                }) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(habit.name)
                                .foregroundColor(.accentColor)
                                .multilineTextAlignment(.leading)
                                .bold()
                            
                            Spacer()
                            
                            Text("\(habit.metrics?.count ?? 0) metrics")
                                .foregroundColor(.secondary)
                                .font(.callout)
                        }
                        
                        if let description = habit.description {
                            Text(description)
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
                .sheet(isPresented: $showModal) {
                    Modal(title: "Create habit") {
                        HabitCreationModalContent(habit: habit)
                    }
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: showModal)
        }
    }

}

struct RecognizedHabitLogging: View {
    @State private var showModal: Bool = false
    @State private var ignored: [String] = []
    @Binding var actions: Actions?

    var body: some View {
        if let loggings = actions?.loggings {
            Text("Log your habits")
                .bold()
                .padding(.top)
                .font(.title3)

            ForEach(loggings.map { ($0.key, $0.value) }, id: \.0) { habitName, submissions in
                ForEach(submissions) { submission in
                    // Don't show submissions with no habit to record to
                    let habitFound = UserCache.shared.habits?
                        .first(where: { $0.name == habitName })
                    
                    Button(action: {
                        showModal.toggle()
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(habitName)
                                    .foregroundColor(.accentColor)
                                    .multilineTextAlignment(.leading)
                                    .bold()
                                
                                Spacer()
                                
                                Text(submission.timestamp.fancyString)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                            
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
                    .buttonStyle(.plain)
                    .contextMenu {
                        // Show delete button on long press
                        Button(role: .destructive) {
                            ignored.append(submission.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .disabled(habitFound == nil || ignored.contains(submission.id))
                    .sheet(isPresented: $showModal) {
                        Modal(title: "Log habit") {
                            if let habitFound = habitFound {
                                HabitLoggingModalContent(
                                    submission: submission,
                                    habit: habitFound
                                ) {
                                    ignored.append(submission.id)
                                }
                            }
                        }
                    }
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: showModal)
        }
    }

}

#Preview {
    VoiceCommandsPageContent()
}
