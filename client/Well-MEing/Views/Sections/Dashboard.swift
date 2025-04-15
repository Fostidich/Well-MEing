import SwiftUI
import FirebaseDatabase

struct Dashboard: View {
    @EnvironmentObject var auth: Authentication

    var body: some View {
        Text("Your tracked habits")
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

        VStack {
            ForEach(UserCache.shared.habits ?? []) { habit in
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
