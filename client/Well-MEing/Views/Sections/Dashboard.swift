import FirebaseDatabase
import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: Authentication

    var body: some View {
        VoiceCommandButton()
        HabitsList()

        HButton(text: "Sign out", textColor: .red) { auth.signOut() }
            .padding(.top)
            .padding(.horizontal)

        // FIXME: remove this button in production
        HButton(text: "Toggle user data", textColor: .red) {
            if UserDefaults.standard.string(forKey: "userUID") == "publicData" {
                UserDefaults.standard.set(auth.user?.uid, forKey: "userUID")
                print("Switched to private data")
            } else {
                UserDefaults.standard.set("publicData", forKey: "userUID")
                print("Switched to public data")
            }
            UserCache.shared.fetchUserData()
        }
        .padding(.horizontal)
    }
}

struct VoiceCommandButton: View {

    var body: some View {
        NavigationLink {
            VoiceCommandsPageContent()
                .navigationTitle("Use your voice")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Image(systemName: "mic.fill")
                    .foregroundColor(.accentColor)
                    .padding(.horizontal)
                Text("Use your voice")
                    .foregroundColor(.accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.accentColor)
            }
            .bold()
            .font(.title3)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.2))
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

struct HabitsList: View {
    @State private var showModal = false
    @State private var showDeleteAlert = false
    @State private var deleteSuccess = false

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
                (UserCache.shared.habits ?? []).sorted {
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
