import FirebaseDatabase
import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: Authentication

    var body: some View {
        // Title with refresh button
        HStack {
            Text("Your tracked habits")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {
                UserCache.shared.fetchUserData()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundColor(.accentColor)
                    .padding()
            }
        }
        .padding(.horizontal)

        // Order habits based on nearest submission
        VStack {
            ForEach(
                (UserCache.shared.habits ?? []).sorted {
                    ($0.lastSubmissionDate ?? Date())
                        > ($1.lastSubmissionDate ?? Date())
                }
            ) { habit in
                HabitButton(habit: habit)
            }
        }
        .padding(.bottom)

        HButton(text: "Sign out", textColor: .red) { auth.signOut() }
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
