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
        
        // adding true timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let currentDate = formatter.string(from: Date())
        details["timestamp"] = currentDate
        
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

func deleteHabitByName(habitName: String) {
    guard !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let databaseRef = Database.database().reference()

    if let userId = UserDefaults.standard.string(forKey: "userUID") {
        let habitsRef = databaseRef.child("users").child(userId).child("habits")

        habitsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let habitSnap = child as? DataSnapshot,
                   let habitData = habitSnap.value as? [String: Any],
                   let name = habitData["name"] as? String,
                   name == habitName {
                    
                    habitsRef.child(habitSnap.key).removeValue { error, _ in
                        if let error = error {
                            print("Error deleting habit: \(error.localizedDescription)")
                        } else {
                            print("Habit '\(habitName)' deleted successfully.")
                        }
                    }
                }
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

func fetchHabits(completion: @escaping ([[String: Any]]) -> Void) {
    guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
        print("User UID not found")
        completion([])
        return
    }

    let databaseRef = Database.database().reference()
    let habitsRef = databaseRef.child("users").child(userId).child("habits")

    habitsRef.observeSingleEvent(of: .value) { snapshot in
        var habits: [[String: Any]] = []

        for child in snapshot.children {
            if let childSnapshot = child as? DataSnapshot,
               var habitData = childSnapshot.value as? [String: Any] {
                habitData["id"] = childSnapshot.key // Add the habit's ID to the dictionary
                habits.append(habitData)
            }
        }

        completion(habits)
    } withCancel: { error in
        print("Failed to fetch habits: \(error.localizedDescription)")
        completion([])
    }
}
