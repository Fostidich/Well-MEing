import FirebaseDatabase

// Function to update the username
func updateUsername(newUsername: String) {
    let databaseRef = Database.database().reference()

    // Ensure user UID is available
    if let userId = UserDefaults.standard.string(forKey: "userUID") {
        let userPath = "users/\(userId)"
        
        // Update only the username field in Firebase
        databaseRef.child(userPath).updateChildValues([
            "username": newUsername
        ]) { (error, ref) in
            if let error = error {
                print("Username update failed: \(error.localizedDescription)")
            } else {
                print("Username updated successfully!")
            }
        }
    } else {
        print("User UID not found in UserDefaults")
    }
}

// Function to update the email
func updateEmail(newEmail: String) {
    let databaseRef = Database.database().reference()

    // Ensure user UID is available
    if let userId = UserDefaults.standard.string(forKey: "userUID") {
        let userPath = "users/\(userId)"
        
        // Update only the email field in Firebase
        databaseRef.child(userPath).updateChildValues([
            "email": newEmail
        ]) { (error, ref) in
            if let error = error {
                print("Email update failed: \(error.localizedDescription)")
            } else {
                print("Email updated successfully!")
            }
        }
    } else {
        print("User UID not found in UserDefaults")
    }
}

func fetchUserData() {
    let databaseRef = Database.database().reference()

        if let userId = UserDefaults.standard.string(forKey: "userUID") {
            let userPath = "users/\(userId)"
            
            databaseRef.child(userPath).observeSingleEvent(of: .value) { snapshot in
                if let userData = snapshot.value as? [String: Any] {
                    let username = userData["username"] as? String
                    let email = userData["email"] as? String
                    
                    // Store in UserDefaults
                    UserDefaults.standard.setValue(username, forKey: "username")
                    UserDefaults.standard.setValue(email, forKey: "email")
                } else {
                    print("User data not found")
                }
            }
        } else {
            print("User UID not found in UserDefaults")
        }
}
