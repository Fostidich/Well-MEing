import Foundation

class Submission: Identifiable, ObservableObject {
    public var id: String?

    public var timestamp: Date
    public var notes: String?
    @Published public var metrics: [String: Any]?

    init(
        id: String? = nil,
        timestamp: Date = Date(),
        notes: String? = nil,
        metrics: [String: Any]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.notes = notes.clean
        self.metrics = metrics
    }

    init?(dict: [String: Any]) {
        guard
            let timestamp = dict["timestamp"] as? String
        else {
            return nil
        }

        let id = dict["id"] as? String
        let notes = dict["notes"] as? String
        let metrics = dict["metrics"] as? [String: Any]

        self.id = id
        self.timestamp = Date.fromString(timestamp)
        self.notes = notes.clean
        self.metrics = metrics
    }

    /// The submission object is serialized as a dictionary.
    /// The ID field is not included, as the DB object does not contain in, as the ID is its key instead.
    /// Firebase will require the returned dictionary to be casted as a ``NSDictionary``, in order to be uploaded.
    var asDict: [String: Any] {
        var dict: [String: Any] = [
            "timestamp": timestamp.longString
        ]
        if let notes = notes.clean {
            dict["notes"] = notes
        }
        if let metrics = metrics {
            dict["metrics"] = metrics
        }
        return dict
    }

}
