import Foundation

class Habit: Identifiable {
    var id: String { name }

    public var name: String
    public var description: String?
    public var goal: String?
    public var metrics: [Metric]
    public var history: [Submission]?

    init(
        name: String,
        description: String? = nil,
        goal: String? = nil,
        metrics: [Metric],
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
            let name = dict["name"] as? String,
            let metrics = dict["metrics"] as? [[String: Any]]
        else {
            return nil
        }

        let history = dict["history"] as? [[String: Any]]
        let description = dict["description"] as? String
        let goal = dict["goal"] as? String

        self.name = name
        self.description = description
        self.goal = goal
        self.metrics = metrics.compactMap { Metric(dict: $0) }
        self.history = history?.compactMap { Submission(dict: $0) }
    }

    var submissionsCount: Int {
        return history?.count ?? 0
    }
    
    var lastSubmissionDate: Date? {
        return history?.max(by: { $0.timestamp < $1.timestamp })?.timestamp
    }
    
}
