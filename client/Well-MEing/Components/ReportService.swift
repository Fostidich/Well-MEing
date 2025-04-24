import FirebaseDatabase
import Foundation

/// At a set cadence, the submissions history of the last period must be received
/// and sent to the AI assistant, for it to generate a user-specific report. This component makes
/// the call to the LLM for receving the report text, allowing the View to also retrieve and show
/// past reports. It also manages the user personal information DB insertions.
struct ReportService {

    /// Since the report may be asked once a week at maximum, this method return the cooldown time
    /// that the user is required to wait before requesting a new report.
    /// If the returned value is `nil`, than the timer is elapsed therefore allowing the user to make a new request.
    static func showTimer() -> String? {
        // TODO: define method
        return nil
    }

    /// After the user selects a list of habits which submissions he want to include for the report generation, this method
    /// (not the caller) calls the ``HistoryManager/retrieveLastWeekSubmissions(habits:)`` method from the ``HistoryManager`` struct.
    /// The submissions, along with the name and bio of the user, are sent to the backend's LLM which hopefully is able to generate a
    /// user-specific report, which is returned after being received.
    /// Note that the name and bio are not required to be set beforehand by the user; they can be empty.
    static func getNewReport(habits: [String]) -> String? {
        // TODO: define method
        return nil
    }

    /// The username of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 4-32
    /// characters long range.
    /// A valid username only contains upper and lower case letters and white spaces.
    /// Numbers and symbols are invalid.
    /// White-space only text is invalid.
    @MainActor static func updateUsername(username: String) -> Bool {
        print("Setting username")

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
            .child("username")

        // Upload value while checking for errors
        var errors = false
        reference.setValue(username) { (error, ref) in
            if let error = error {
                print("Error setting username: \(error.localizedDescription)")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }

    /// The bio of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 8-256
    /// characters long range.
    /// A valid bio only can contain whichever character (lower/upper case letters, numbers, symbols, spaces), but white-space only text is invalid.
    @MainActor static func updateBio(bio: String) -> Bool {
        print("Setting bio")

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
            .child("bio")

        // Upload value while checking for errors
        var errors = false
        reference.setValue(bio) { (error, ref) in
            if let error = error {
                print("Error setting bio: \(error.localizedDescription)")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }

}
