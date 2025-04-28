import FirebaseDatabase
import Foundation

@MainActor
@Observable
class UserCache {
    /// This is the singleton user cache object that can be consulted statically from everywhere.
    static let shared = UserCache()

    var name: String? = nil
    var bio: String? = nil
    var habits: [Habit]? = nil
    var newReportDate: Date? = nil
    var reports: [Report]? = nil

    /// Private initializer is empty to ensure this class is a singleton.
    private init() {}

    /// User cache data is initialized/updated from a dictionary containing this class' fields.
    /// Specific adjustments are made on the received dictionary, as to resemble the specific DB structure
    /// found on Firebase.
    func fromDictionary(_ dictionary: [String: Any]?) {
        guard let dictionary = dictionary else { return }

        self.name = (dictionary["name"] as? String).clean.map {
            String($0.prefix(50))
        }
        self.bio = (dictionary["bio"] as? String).clean.map {
            String($0.prefix(500))
        }

        if let habitsDict = dictionary["habits"] as? [String: [String: Any]] {
            let fixHabits = habitsDict.compactMap { (key, value) in
                var habitData = value
                habitData["name"] = key
                return Habit(dict: habitData)
            }
            
            self.habits = fixHabits.isEmpty ? nil : fixHabits
        }
        
        if let newReportDate = dictionary["newReportDate"] as? String {
            self.newReportDate = Date.fromString(newReportDate)
        }
        
        if let reportsDict = dictionary["reports"] as? [String: [String: Any]] {
            let fixReports = reportsDict.compactMap { (key, value) in
                var reportData = value
                reportData["date"] = key
                return Report(dict: reportData)
            }
            
            self.reports = fixReports.isEmpty ? nil : fixReports
        }
    }

    /// The whole user data in the DB is fetched and put into the ``UserCache`` class.
    /// Its variables are static and can be retrieve from everywhere.
    /// - SeeAlso: ``UserCache`` contains static data of the user.
    func fetchUserData() {
        print("Fetching user data")

        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return
        }

        // Get db reference and navigate the required data path
        let reference =
            Database
            .database()
            .reference()
            .child("users")
            .child(userId)

        // Download user data
        reference.observeSingleEvent(
            of: .value,
            with: { snapshot in
                // Get data if found
                if let data = snapshot.value as? [String: Any] {
                    // Map the data into objects
                    Task { @MainActor in
                        self.fromDictionary(data)
                    }
                } else {
                    print("Error while receving user data")
                }
            }
        )
    }

}
