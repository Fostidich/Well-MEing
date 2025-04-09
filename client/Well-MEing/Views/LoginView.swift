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

            VStack(spacing: 40) {
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

                Spacer().frame(height: 64)

                // Auth invitation text above the button
                Text("Please log in or sign in")
                    .font(.title3)
                    .foregroundColor(.primary.opacity(0.8))

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
}
