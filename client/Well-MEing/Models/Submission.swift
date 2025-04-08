import Foundation

class Submission {

    public var habit: String
    public var timestamp: Date
    public var notes: String?
    public var metrics: [String: Any]

    init(habit: String, timestamp: Date, notes: String?, metrics: [String: Any])
    {
        self.habit = habit
        self.timestamp = timestamp
        self.notes = notes
        self.metrics = metrics
    }

}
