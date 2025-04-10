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
                    HStack {
                        Text(habit.name)
                            .bold()
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(String(habit.submissionsCount))
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()

                    Text(habit.description ?? "")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .padding(.horizontal)
            .sheet(isPresented: $showModal) {
                //                HabitModal(habit: Habit)
            }
        }
    }
}
