import SwiftUI

struct LogHabitsList: View {
    @State private var showModal = false
    @State private var showDeleteAlert = false
    @State private var deleteSuccess = false
    @ObservedObject var cache = UserCache.shared

    var body: some View {
        // Title for habits list
        Text("Your tracked habits")
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom)

        // Order habits based on nearest submission
        VStack {
            ForEach(
                (cache.habits ?? []).sorted {
                    ($0.lastSubmissionDate ?? Date())
                        > ($1.lastSubmissionDate ?? Date())
                }
            ) { habit in
                HabitButton(
                    habit: habit, showDeleteAlert: $showDeleteAlert,
                    deleteSuccess: $deleteSuccess)
            }
        }
        .alert(
            deleteSuccess
                ? "Habit deleted successfully" : "Failed to delete habit",
            isPresented: $showDeleteAlert
        ) {
            Button("OK", role: .cancel) {}
        }

        // Create habit button
        Button(action: {
            showModal.toggle()
        }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))

                // Button content
                Image(systemName: "plus")
                    .bold()
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .padding()
            }
        }
        .disabled((cache.habits?.count ?? 0) >= 10)
        .sheet(isPresented: $showModal) {
            // Open the habit creation modal
            Modal(title: "Create an habit", dismissButton: .cancel) {
                HabitCreationModalContent()
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: showModal)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

