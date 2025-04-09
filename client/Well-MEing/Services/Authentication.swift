import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class Authentication: ObservableObject {
    @Published var user: User?

    init() {
        self.user = Auth.auth().currentUser
    }

    func signIn(with presentingViewController: UIViewController) {
        // Retrieve the client ID
        guard
            let clientID = FirebaseApp.app()?.options.clientID
        else {
            print("Error: unable to retrieve client ID")
            return
        }

        // Store client ID in Google sign-in configs
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Pass this sign-in function to Google sign-in instance
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        ) { [weak self] result, error in
            // Find user ID token
            guard
                let self = self,
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("Error: unable to retrieve user ID token")
                return
            }

            // Set credentials as user ID token and access token
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            // Sign-in with the prepared credentials
            Auth.auth().signIn(with: credential) { authResult, error in
                // Manage sign-in errors
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                // Retrieve Firebase user
                guard let firebaseUser = authResult?.user
                else {
                    print("Error: unable to retrieve Firebase user")
                    return
                }

                // Set authenticated user as the Firebase user
                self.user = firebaseUser

                // Store the Firebase user UID locally in UserDefaults
                UserDefaults.standard.set(firebaseUser.uid, forKey: "userUID")
            }
        }
    }

    func signOut() {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()

        // Sign out from Firebase
        try? Auth.auth().signOut()

        // Update the published property
        self.user = nil

        // Empty user defaults
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
    }
}
