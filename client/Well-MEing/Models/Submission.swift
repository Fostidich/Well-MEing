import Foundation

class Submission {
    public var timestamp: Date
    public var habit: String
    public var metrics: [String: Any]

    init(timestamp: Date, habit: String, metrics: [String: Any]) {
        self.timestamp = timestamp
        self.habit = habit
        self.metrics = metrics
    }

}
