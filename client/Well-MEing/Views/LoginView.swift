import FirebaseAuth
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @ObservedObject var auth: Authentication

    var body: some View {
        ZStack {
            // Color gradient in background
            LinearGradient(
                gradient: Gradient(
                    colors: [.accentColor, .secondary.opacity(0.50)]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Introduction texts
                VStack {
                    Text("Welcome to")
                        .font(.title3)
                        .foregroundColor(.primary.opacity(0.5))
                    Text("Well MEing")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.primary)
                }
                .padding(.top, 50)
                .transition(.opacity)

                Spacer().frame(height: 400)

                // Log in button with Google sign-in
                Button(action: handleSignIn) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .foregroundColor(.primary)
                    .frame(width: 250, height: 50)
                    .background(.secondary.opacity(0.8))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                }

                // FIXME: remove this button in production
                // Log in button for guests
                Button(action: publicLogIn) {
                    Text("Public access")
                        .font(.headline)
                        .underline()
                        .foregroundColor(.primary)
                        .shadow(radius: 3)
                        .padding()
                }
                .padding()

                Spacer()
            }
            .padding()
        }
    }

    func handleSignIn() {
        if let windowScene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene,
            let rootViewController = windowScene.windows.first?
                .rootViewController
        {
            auth.signIn(with: rootViewController)
        }
    }

    // FIXME: remove this function in production
    func publicLogIn() {
        let dummyUser = unsafeBitCast(NSMutableDictionary(), to: User.self)
        auth.user = dummyUser
        UserDefaults.standard.set("publicData", forKey: "userUID")
    }

}

#Preview {
    let auth = Authentication()
    LoginView(auth: auth)
}
