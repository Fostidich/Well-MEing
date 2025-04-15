import Foundation

class Habit: Identifiable {
    var id: String { name }

    public var name: String
    public var description: String?
    public var goal: String?
    public var metrics: [Metric]?
    public var history: [Submission]?

    init(
        name: String,
        description: String? = nil,
        goal: String? = nil,
        metrics: [Metric]? = nil,
        history: [Submission]? = nil
    ) {
        self.name = name
        self.description = description
        self.goal = goal
        self.metrics = metrics
        self.history = history
    }

    init?(dict: [String: Any]) {
        guard
            let name = dict["name"] as? String
        else {
            return nil
        }

        let description = dict["description"] as? String
        let goal = dict["goal"] as? String
        let metrics = dict["metrics"] as? [[String: Any]]

        self.name = name
        self.description = description
        self.goal = goal
        self.metrics = metrics?.compactMap { Metric(dict: $0) }
        
        if let historyDict = dict["history"] as? [String: [String: Any]] {
            self.history = historyDict.compactMap { (key, value) in
                var submissionData = value
                submissionData["id"] = key
                return Submission(dict: submissionData)
            }
        }
    }

    /// This is the number corresponding to the total count of submissions made for this habit.
    var submissionsCount: Int {
        return history?.count ?? 0
    }
    
    /// This is the date of the most recent submission for this habit.
    var lastSubmissionDate: Date? {
        return history?.max(by: { $0.timestamp < $1.timestamp })?.timestamp
    }
    
}
