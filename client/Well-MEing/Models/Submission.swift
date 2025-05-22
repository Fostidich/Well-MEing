import Foundation

class Submission: Identifiable, Deserializable {
    public var id: String

    public let timestamp: Date
    public let notes: String?
    public let metrics: [String: Any]?

    init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        notes: String? = nil,
        metrics: [String: Any]? = nil
    ) {
        self.id = id.clean.map { String($0.prefix(50)) } ?? UUID().uuidString
        self.timestamp = timestamp
        self.notes = notes.clean.map { String($0.prefix(500)) }
        self.metrics = (metrics?.isEmpty ?? true) ? nil : metrics
    }

    required init?(dict: [String: Any]) {
        guard
            let timestamp = dict["timestamp"] as? String,
            let timestamp = Date.fromString(timestamp)
        else {
            return nil
        }

        let id = dict["id"] as? String
        let notes = dict["notes"] as? String
        let metrics = dict["metrics"] as? [String: Any]

        self.id = id.clean.map { String($0.prefix(50)) } ?? UUID().uuidString
        self.timestamp = timestamp
        self.notes = notes.clean.map { String($0.prefix(500)) }
        self.metrics = (metrics?.isEmpty ?? true) ? nil : metrics
    }

    /// The submission object is serialized as a dictionary.
    /// The ID field is not included, as the DB object does not contain in, as the ID is its key instead.
    /// Firebase will require the returned dictionary to be casted as a ``NSDictionary``, in order to be uploaded.
    var asDBDict: NSDictionary {
        var dict: [String: Any] = [
            "timestamp": timestamp.toString
        ]
        if let notes = notes {
            dict["notes"] = notes
        }
        if let metrics = metrics {
            dict["metrics"] = metrics
        }
        return dict as NSDictionary
    }

}
