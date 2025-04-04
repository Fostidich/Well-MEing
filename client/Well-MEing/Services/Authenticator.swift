import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    @Published var user: User?

    init() {
        self.user = Auth.auth().currentUser
    }

    func signIn(with presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        ) { [weak self] result, error in
            guard let self = self, let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // Handle error if no user or idToken
                print("Error: No user or token found.")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Sign-in error: \(error.localizedDescription)")
                    return
                }

                // After successful Firebase sign-in, retrieve the Firebase user
                guard let firebaseUser = authResult?.user else { return }
                self.user = firebaseUser
                
                updateEmail(newEmail: firebaseUser.email ?? "")

                // Store the Firebase user UID locally (e.g., in UserDefaults or elsewhere)
                self.storeUserUID(firebaseUser.uid)
            }
        }
    }

    // Function to store UID locally (using UserDefaults in this case)
    func storeUserUID(_ uid: String) {
        UserDefaults.standard.set(uid, forKey: "userUID")
        print("Stored user UID: \(uid)")
    }

    func signOut() {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()

        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
            // Update the published property
            self.user = nil
        } catch {
        }
    }
}
