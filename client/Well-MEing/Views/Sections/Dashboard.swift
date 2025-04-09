import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: Authentication
    
    var body: some View {
        Text("Dashboard")
        Text(UserDefaults.standard.string(forKey: "userUID") ?? "none")

        Button(action: {
            auth.signOut()
        }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))

                // Content of the task button
                Text("Log out")
                    .bold()
                    .foregroundColor(.red)
                    .padding()
            }
            .padding()
        }
    }
}
