import Foundation

class UserCache: ObservableObject {
    
    /// This is the singleton user cache object that can be consulted statically from everywhere.
    @MainActor static var shared = UserCache()

    @Published var name: String? = nil
    @Published var bio: String? = nil
    @Published var habits: [Habit]? = nil
    @Published var newReportDate: Date? = nil
    @Published var reports: [Report]? = nil

    /// Private initializer is empty to ensure this class is a singleton.
    private init() {}

    /// User cache data is initialized/updated from a dictionary containing this class' fields.
    /// Specific adjustments are made on the received dictionary, as to resemble the specific DB structure
    /// found on Firebase.
    func fromDictionary(_ dictionary: [String: Any]?) {
        // Accept nil dict as it means "everything is nil"
        let dict = dictionary ?? [:]
        
        // Name
        self.name = (dict["name"] as? String).clean.map {
            String($0.prefix(50))
        }

        // Bio
        self.bio = (dict["bio"] as? String).clean.map {
            String($0.prefix(500))
        }

        // Habits
        let habitsDict = dict["habits"] as? [String: [String: Any]]
        let fixHabits = habitsDict?.compactMap { (key, value) in
            var habitData = value
            habitData["name"] = key
            return Habit(dict: habitData)
        }
        self.habits = (fixHabits?.isEmpty ?? true) ? nil : fixHabits

        // New report date
        self.newReportDate = (dict["newReportDate"] as? String).flatMap {
            Date.fromString($0)
        }

        // Reports
        let reportsDict = dict["reports"] as? [String: [String: Any]]
        let fixReports = reportsDict?.compactMap { (key, value) in
            var reportData = value
            reportData["date"] = key
            return Report(dict: reportData)
        }
        self.reports = (fixReports?.isEmpty == true) ? nil : fixReports
    }

    /// Update user cache data.
    /// This call is forwarded to the ``Request/fetchUserData()`` method.
    let fetchUserData = Request.fetchUserData

}
