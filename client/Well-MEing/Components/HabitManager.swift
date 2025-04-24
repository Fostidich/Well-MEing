import FirebaseDatabase
import Foundation

/// The habit manager collects all the functions that are used for creating, editing
/// and deleting the habits that the user is tracking, each with its internal metrics. Furthermore,
/// it contains the call needed for logging an habit submission.
struct HabitManager {

    /// Given an habit (e.g. built from user input), it is inserted in the backend's DB.
    /// There must not be an habit with the same name for the user, as the name is used as unique key.
    /// The metrics must contain a valid input type, with all its required configuration values.
    /// - SeeAlso: ``InputType`` shows all available input types and the configurations they require.
    @MainActor static func createHabit(habit: Habit) -> Bool {
        print("Creating new habit")

        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return false
        }

        // Get db reference and navigate the required data path
        let reference =
            Database
            .database()
            .reference()
            .child("users")
            .child(userId)
            .child("habits")
            .child(habit.name)

        // Upload value while checking for errors
        var errors = false
        reference.setValue(habit.asDBDict as NSDictionary) { (error, ref) in
            if let error = error {
                print("Error creating habit: \(error.localizedDescription)")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }

    /// By providing the name of an habit,
    /// that habit is deleted from the backend's DB.
    @MainActor static func deleteHabit(habitName: String) -> Bool {
        print("Deleting habit")

        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return false
        }

        // Get db reference and navigate the required data path
        let reference =
            Database
            .database()
            .reference()
            .child("users")
            .child(userId)
            .child("habits")
            .child(habitName)

        // Upload value while checking for errors
        var errors = false
        reference.removeValue { error, _ in
            if let error = error {
                print("Error deleting habit: \(error.localizedDescription)")
                errors = true
            }
        }
        
        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }
    
    /// Given a submission for an habit, it is recorded in the backend's DB for that habit's history.
    /// There must not be a submission for that habit with the same timestamp, as the timestamp is used as unique key.
    /// The submission's metrics must coincide with all the metrics defined in the habit "template", and they cannot be empty.
    /// - SeeAlso: ``InputType`` shows all available input types and the configurations they require.
    @MainActor static func createSubmission(
        habit: String, submission: Submission
    ) -> Bool {
        print("Creating new submission")

        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return false
        }

        // Get db reference and navigate the required data path
        let reference =
            Database
            .database()
            .reference()
            .child("users")
            .child(userId)
            .child("habits")
            .child(habit)
            .child("history")
            .childByAutoId()

        // Upload value while checking for errors
        var errors = false
        reference.setValue(submission.asDBDict as NSDictionary) { (error, ref) in
            if let error = error {
                print("Error creating submission: \(error.localizedDescription)")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }

    /// By providing the name of an habit and the ID of a submission,
    /// that submission is deleted from the backend's DB.
    @MainActor static func deleteSubmission(habitName: String, id: String) -> Bool {
        print("Deleting submission")

        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return false
        }

        // Get db reference and navigate the required data path
        let reference =
            Database
            .database()
            .reference()
            .child("users")
            .child(userId)
            .child("habits")
            .child(habitName)
            .child("history")
            .child(id)

        // Upload value while checking for errors
        var errors = false
        reference.removeValue { error, _ in
            if let error = error {
                print("Error deleting submission: \(error.localizedDescription)")
                errors = true
            }
        }
        
        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }
    
}
