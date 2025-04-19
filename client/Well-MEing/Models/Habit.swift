import Foundation

class Habit: Identifiable {
    var id: String { name }

    public let name: String
    public let description: String?
    public let goal: String?
    public let metrics: [Metric]?
    public let history: [Submission]?

    init?(
        name: String,
        description: String? = nil,
        goal: String? = nil,
        metrics: [Metric]? = nil,
        history: [Submission]? = nil
    ) {
        guard let name = name.clean?.prefix(50) else {
            return nil
        }
        self.name = String(name)
        self.description = description.clean.map { String($0.prefix(500)) }
        self.goal = goal.clean.map { String($0.prefix(500)) }
        self.metrics = (metrics?.isEmpty ?? true) ? nil : metrics
        self.history = (history?.isEmpty ?? true) ? nil : history
    }

    init?(dict: [String: Any]) {
        guard
            let name = dict["name"] as? String
        else {
            return nil
        }

        let description = dict["description"] as? String
        let goal = dict["goal"] as? String

        self.name = String(name.prefix(50))
        self.description = description.clean.map { String($0.prefix(500)) }
        self.goal = goal.clean.map { String($0.prefix(500)) }

        var fixMetrics: [Metric]?
        var fixHistory: [Submission]?

        if let metricsDict = dict["metrics"] as? [String: [String: Any]] {
            fixMetrics = metricsDict.compactMap { (key, value) in
                var metricData = value
                metricData["name"] = key
                return Metric(dict: metricData)
            }
        }
        if let historyDict = dict["history"] as? [String: [String: Any]] {
            fixHistory = historyDict.compactMap { (key, value) in
                var submissionData = value
                submissionData["id"] = key
                return Submission(dict: submissionData)
            }
        }

        self.metrics = (fixMetrics?.isEmpty ?? true) ? nil : fixMetrics
        self.history = (fixHistory?.isEmpty ?? true) ? nil : fixHistory
    }

    /// This is the number corresponding to the total count of submissions made for this habit.
    var submissionsCount: Int {
        return history?.count ?? 0
    }

    /// This is the date of the most recent submission for this habit.
    var lastSubmissionDate: Date? {
        return history?.max(by: { $0.timestamp < $1.timestamp })?.timestamp
    }

    /// The habit object is serialized as a dictionary.
    /// The name field is not included, as the DB object does not contain in, as the name is its key instead.
    /// The ID field is also not included, as it is a redundancy for the name.
    /// Firebase will require the returned dictionary to be casted as a ``NSDictionary``, in order to be uploaded.
    var asDict: [String: Any] {
        var dict: [String: Any] = [
            "history": ""
        ]
        if let description = description {
            dict["description"] = description
        }
        if let goal = goal {
            dict["goal"] = goal
        }
        if let metrics = metrics {
            dict["metrics"] = metrics.reduce(into: [:]) { result, metric in
                result[metric.name] = metric.asDict
            }
        }
        return dict
    }

}
