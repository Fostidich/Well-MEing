import FirebaseDatabase
import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: Authentication

    var body: some View {
        VoiceCommandButton()
        LogHabitsList()

        HButton(text: "Sign out", textColor: .red) { auth.signOut() }
            .padding(.top)
            .padding(.horizontal)

        #if DEBUG
            HButton(text: "Toggle user data", textColor: .red) {
                if UserDefaults.standard.string(forKey: "userUID")
                    == "publicData"
                {
                    UserDefaults.standard.set(auth.user?.uid, forKey: "userUID")
                    print("Switched to private data")
                } else {
                    UserDefaults.standard.set("publicData", forKey: "userUID")
                    print("Switched to public data")
                }
                UserCache.shared.fetchUserData()
            }
            .padding(.horizontal)
        #endif

        #if DEBUG
            HButton(text: "Reset report timer", textColor: .red) {
                UserCache.shared.newReportDate = nil
                print("Local reset of new report date")
            }
            .padding(.horizontal)
        #endif
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
