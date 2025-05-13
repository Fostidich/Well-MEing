import FirebaseDatabase
import Foundation
import SwiftUI

// TODO: delete this file

/// At a set cadence, the submissions history of the last period must be received
/// and sent to the AI assistant, for it to generate a user-specific report. This component makes
/// the call to the LLM for receiving the report text, allowing the View to also retrieve and show
/// past reports. It also manages the user personal information DB insertions.
struct ReportService {

    /// After the user selects a list of habits which submissions he want to include for the report generation, this method
    /// (not the caller) calls the ``HistoryManager/retrieveLastMonthSubmissions(habits:)`` method from the ``HistoryManager`` struct.
    /// The submissions, along with the name and bio of the user, are sent to the backend's LLM which hopefully is able to generate a
    /// user-specific report, which is returned after being received.
    /// Note that the name and bio are not required to be set beforehand by the user; they can be empty.
    @MainActor static func getNewReport(
        habits: [String], report: Binding<Report?>
    ) async -> Bool {
        print("Generating report")

        // Reset recipient object
        report.wrappedValue = nil

        // Get required data to send
        var lastMonthHabits: [String: NSDictionary] = [:]
        HistoryManager
            .habitsWithLastMonthSubmissions(habits: habits)
            .forEach {
                lastMonthHabits[$0.name] = $0.asDBDict
            }

        // Check that URL endpoint is valid
        guard let url = Request.generateReport().path
        else { return false }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = [
            "habits": lastMonthHabits
        ]
        if let name = UserCache.shared.name {
            body["name"] = name
        }
        if let bio = UserCache.shared.bio {
            body["bio"] = bio
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        var errors = false
        do {
            // Send request to function
            let (data, _) = try await URLSession.shared.data(for: request)

            // Deserialize response
            if let json = try JSONSerialization.jsonObject(with: data)
                as? [String: Any]
            {
                report.wrappedValue = Report(dict: json)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            errors = true
        }

        // Update user local data
        Task { @MainActor in UserCache.shared.fetchUserData() }
        return !errors
    }

    /// Since requesting a new report does not automatically upload it to the DB, when received,
    /// it has to be added to the report list of the backend's DB.
    /// This method should be called directly after receiving the new report from the Firebase function call.
    /// A report is identified by the timestamp of when it was generated, which works like a unique key.
    @MainActor static func uploadReport(report: Report) -> Bool {
        // FIXME: move this logic to backend
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
                print(
                    "Error while uploading report: \(error.localizedDescription)"
                )
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
        reference.removeValue { (error, ref) in
            if let error = error {
                print(
                    "Error while deleting report: \(error.localizedDescription)"
                )
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        Thread.sleep(forTimeInterval: 1)
        return !errors
    }

    /// After requesting a report, the date of when a new report may be requested must be updated.
    /// It is updated to 7 days from now, at 00:00.
    @MainActor static func updateTimer() -> Bool {
        // FIXME: move this logic to backend
        print("Updating report date")

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
            .child("newReportDate")

        // Build new value
        let calendar = Calendar.current
        guard
            let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date()),
            let futureMidnight = calendar.date(
                bySettingHour: 0, minute: 0, second: 0, of: nextWeek)
        else { return false }

        // Upload value while checking for errors
        var errors = false
        reference.setValue(futureMidnight.toString) { (error, ref) in
            if let error = error {
                print(
                    "Error while updating new report date: \(error.localizedDescription)"
                )
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
        print("Updating name")

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
                    print(
                        "Error while setting name: \(error.localizedDescription)"
                    )
                    errors = true
                }
            }
        } else {
            reference.removeValue { (error, ref) in
                if let error = error {
                    print(
                        "Error while deleting name: \(error.localizedDescription)"
                    )
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
        print("Updating bio")

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
                    print(
                        "Error while setting bio: \(error.localizedDescription)"
                    )
                    errors = true
                }
            }
        } else {
            reference.removeValue { (error, ref) in
                if let error = error {
                    print(
                        "Error while deleting bio: \(error.localizedDescription)"
                    )
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
