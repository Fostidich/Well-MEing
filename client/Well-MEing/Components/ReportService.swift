import FirebaseDatabase
import Foundation
import SwiftUI

/// At a set cadence, the submissions history of the last period must be received
/// and sent to the AI assistant, for it to generate a user-specific report. This component makes
/// the call to the LLM for receving the report text, allowing the View to also retrieve and show
/// past reports. It also manages the user personal information DB insertions.
struct ReportService {

    /// After the user selects a list of habits which submissions he want to include for the report generation, this method
    /// (not the caller) calls the ``HistoryManager/retrieveLastWeekSubmissions(habits:)`` method from the ``HistoryManager`` struct.
    /// The submissions, along with the name and bio of the user, are sent to the backend's LLM which hopefully is able to generate a
    /// user-specific report, which is returned after being received.
    /// Note that the name and bio are not required to be set beforehand by the user; they can be empty.
    @MainActor static func getNewReport(
        habits: [String], report: Binding<Report?>
    ) async -> Bool {
        // TODO: define method
        report.wrappedValue = nil
        report.wrappedValue = Report(
            title: "Report title",
            date: Date(),
            content: "Report content"
        )
        return true
    }

    /// Since requesting a new report does not automatically upload it to the DB, when received,
    /// it has to be added to the report list of the backend's DB.
    /// This method should be called directly after receiving the new report from the Firebase function call.
    /// A report is identified by the timestamp of when it was generated, which works like a unique key.
    @MainActor static func uploadReport(report: Report) -> Bool {
        print("Uploading report")

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
            .child("reports")
            .child(report.date.toString)

        // Upload value while checking for errors
        var errors = false
        reference.setValue(report.asDBDict) { (error, ref) in
            if let error = error {
                print("Error while uploading report: \(error.localizedDescription)")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }
    
    /// By providing the date of a report,
    /// that report is deleted from the backend's DB.
    @MainActor static func deleteReport(date: Date) -> Bool {
        print("deleting report")

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
            .child("reports")
            .child(date.toString)

        // Upload value while checking for errors
        var errors = false
        reference.removeValue() { (error, ref) in
            if let error = error {
                print("Error while deleting report: \(error.localizedDescription)")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }
    
    /// The username of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 4-32
    /// characters long range.
    /// A valid username only contains upper and lower case letters and white spaces.
    /// Numbers and symbols are invalid.
    /// White-space only text is invalid.
    @MainActor static func updateName(name: String?) -> Bool {
        print("Setting name")

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
            .child("name")

        // Upload value while checking for errors
        var errors = false
        if let name = name {
            reference.setValue(name) { (error, ref) in
                if let error = error {
                    print("Error while setting name: \(error.localizedDescription)")
                    errors = true
                }
            }
        } else {
            reference.removeValue { (error, ref) in
                if let error = error {
                    print("Error while deleting name: \(error.localizedDescription)")
                    errors = true
                }
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
    @MainActor static func updateBio(bio: String?) -> Bool {
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
        if let bio = bio {
            reference.setValue(bio) { (error, ref) in
                if let error = error {
                    print("Error while setting bio: \(error.localizedDescription)")
                    errors = true
                }
            }
        } else {
            reference.removeValue { (error, ref) in
                if let error = error {
                    print("Error while deleting bio: \(error.localizedDescription)")
                    errors = true
                }
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }

}
