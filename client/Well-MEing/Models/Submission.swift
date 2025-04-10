import Foundation

class Submission {
    public var timestamp: Date
    public var notes: String?
    public var metrics: [String: Any]

    init(timestamp: Date, notes: String? = nil, metrics: [String: Any]) {
        self.timestamp = timestamp
        self.notes = notes
        self.metrics = metrics
    }

    init?(dict: [String: Any]) {
        guard
            let timestamp = dict["timestamp"] as? String,
            let metrics = dict["metrics"] as? [String: Any]
        else {
            return nil
        }

        let notes = dict["notes"] as? String

        self.timestamp = Date.fromString(timestamp)
        self.notes = notes
        self.metrics = metrics
    }

}
