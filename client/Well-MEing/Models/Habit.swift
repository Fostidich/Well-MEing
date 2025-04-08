class Habit {
    public var name: String
    public var description: String
    public var goal: String
    public var metrics: [Metric]
    public var history: [Submission]

    init(
        name: String, description: String, goal: String, metrics: [Metric],
        history: [Submission]
    ) {
        self.name = name
        self.description = description
        self.goal = goal
        self.metrics = metrics
        self.history = history
    }

}
