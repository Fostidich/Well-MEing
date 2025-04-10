import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: Authentication
    @State private var habits: [Habit]?
    @State private var error: Bool = false

    var body: some View {
        VStack {
            if error {
                Text("Unable to retrieve habits")
            } else if let habits = habits {
                if habits.isEmpty {
                    Text("No habit found")
                } else {
                    ForEach(habits) { habit in
                        HabitButton(habit: habit)
                    }
                }
            } else {
                Text("Loading habits...")
            }
        }
        .onAppear {
            error = !HabitManager.getHabits { fetchedHabits in
                self.habits = fetchedHabits
            }
        }
        .padding(.vertical)

        HButton(text: "Log out", textColor: .red) { auth.signOut() }
    }
}
