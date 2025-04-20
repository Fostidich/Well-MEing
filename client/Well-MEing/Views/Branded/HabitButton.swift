import SwiftUI

struct HabitButton: View {
    let habit: Habit
    @GestureState private var isDetectingLongPress = false
    @State private var showModal = false
    @State private var showDeleteButton = false
    @State private var tapped = false
    @Binding var showDeleteAlert: Bool
    @Binding var deleteSuccess: Bool

    var body: some View {
        // Prevent long press to interfear with short press
        let longPress = LongPressGesture()
            .updating($isDetectingLongPress) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { _ in
                showDeleteButton.toggle()
            }

        // Define short press tap gesture
        let tap = TapGesture()
            .onEnded {
                if !isDetectingLongPress {
                    showModal.toggle()
                }
            }

        // Place the habit button
        Button(action: { showModal.toggle() }) {
            if showDeleteButton {
                HButton(
                    text: "Delete",
                    textColor: .white,
                    backgroundColor: tapped ? .secondary : .red
                ) {
                    tapped = true

                    // Defer action to next runloop so UI can update first
                    DispatchQueue.main.async {
                        deleteSuccess =
                            HabitManager
                            .deleteHabit(habitName: habit.name)
                        showDeleteAlert = true
                        tapped = false
                        showDeleteButton.toggle()
                    }
                }
                .disabled(tapped)
                .frame(maxWidth: 100)
            }

            HabitButtonContent(habit: habit)
                .gesture(longPress.simultaneously(with: tap))
        }
        .padding(.horizontal)
        .sheet(isPresented: $showModal) {
            Modal(title: "Log an habit") {
                HabitLoggingModalContent(habit: habit)
            }
        }
    }

}

struct HabitButtonContent: View {
    let habit: Habit

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
    }
}
