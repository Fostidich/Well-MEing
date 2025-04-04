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

// Function to update the bio
func updateBio(newBio: String) {
    let databaseRef = Database.database().reference()

    // Ensure user UID is available
    if let userId = UserDefaults.standard.string(forKey: "userUID") {
        let userPath = "users/\(userId)"
        
        // Update only the email field in Firebase
        databaseRef.child(userPath).updateChildValues([
            "bio": newBio
        ]) { (error, ref) in
            if let error = error {
                print("Bio update failed: \(error.localizedDescription)")
            } else {
                print("Bio updated successfully!")
            }
        }
    } else {
        print("User UID not found in UserDefaults")
    }
}

// Function to insert a new habit
func insertHabit(newHabit: String, habitDetails: [String: Any]) {
    guard !newHabit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let databaseRef = Database.database().reference()

    // Ensure user UID is available
    if let userId = UserDefaults.standard.string(forKey: "userUID") {
        let habitsRef = databaseRef.child("users").child(userId).child("habits").childByAutoId()
        
        var details = habitDetails
        details["name"] = newHabit  // Store the name inside the object

        
        // Update all fields in the habit
        habitsRef.setValue(details) { (error, ref) in
            if let error = error {
                print("Habit update failed: \(error.localizedDescription)")
            } else {
                print("Habit updated successfully!")
            }
        }
    } else {
        print("User UID not found in UserDefaults")
    }
}

// Function to insert a new element to history
func insertHistory(newHabit: String, historyDetails: [String: Any]) {
    guard !newHabit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let databaseRef = Database.database().reference()

    // Ensure user UID is available
    if let userId = UserDefaults.standard.string(forKey: "userUID") {
        let historyRef = databaseRef.child("users").child(userId).child("history").childByAutoId()
        
        var details = historyDetails
        details["habit"] = newHabit  // Store which habit this history entry belongs to
        
        // Update all fields in the habit
        historyRef.setValue(details) { (error, ref) in
            if let error = error {
                print("History update failed: \(error.localizedDescription)")
            } else {
                print("History updated successfully!")
            }
        }
    } else {
        print("User UID not found in UserDefaults")
    }
}

// Function to fetch the user data
func fetchUserData() {
    let databaseRef = Database.database().reference()

        if let userId = UserDefaults.standard.string(forKey: "userUID") {
            let userPath = "users/\(userId)"
            
            databaseRef.child(userPath).observeSingleEvent(of: .value) { snapshot in
                if let userData = snapshot.value as? [String: Any] {
                    let username = userData["username"] as? String
                    let email = userData["email"] as? String
                    let bio = userData["bio"] as? String
                    let habits = userData["habits"] as? [String: Any]
                    
                    // Store in UserDefaults
                    UserDefaults.standard.setValue(username, forKey: "username")
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue(bio, forKey: "bio")
                    UserDefaults.standard.setValue(habits, forKey: "habits")
                } else {
                    print("User data not found")
                }
            }
        } else {
            print("User UID not found in UserDefaults")
        }
}
