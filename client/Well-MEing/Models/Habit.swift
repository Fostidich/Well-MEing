import Foundation

class Habit: Identifiable {
    public var id: String { name }

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
            let name = dict["name"] as? String,
            let name = name.clean
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

    /// The habit object is serialized as a dictionary.
    /// The name field is not included, as the DB object does not contain in, as the name is its key instead.
    /// The ID field is also not included, as it is a redundancy for the name.
    /// Firebase will require the returned dictionary to be casted as a ``NSDictionary``, in order to be uploaded.
    var asDBDict: NSDictionary {
        // Description is made an empty string if absent, working as a dummy to not delete the habit if emptied
        var dict: [String: Any] = [
            "description": description ?? ""
        ]
        if let history = history {
            dict["history"] =
                history
                .compactMap { $0.asDBDict }
        }
        if let metrics = metrics {
            dict["metrics"] = metrics.reduce(into: [:]) {
                $0[$1.name] = $1.asDBDict
            }
        }
        if let goal = goal {
            dict["goal"] = goal
        }
        return dict as NSDictionary
    }

    /// This is the number corresponding to the total count of submissions made for this habit.
    var submissionsCount: Int {
        return history?.count ?? 0
    }

    /// This is the date of the most recent submission for this habit.
    var lastSubmissionDate: Date? {
        return history?.max(by: { $0.timestamp < $1.timestamp })?.timestamp
    }

    /// For each metric (key) the input type (value) is specified.
    var metricTypes: [String: InputType] {
        return metrics?.reduce(into: [String: InputType]()) { dict, metric in
            dict[metric.name] = metric.input
        } ?? [:]
    }

    /// All the submissions made for the habit on the provided day are returned.
    func getSubmissions(day: Date) -> [Submission] {
        return history?.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: day)
        } ?? []
    }

}
