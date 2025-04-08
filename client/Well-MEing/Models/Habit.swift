class Habit {

    public var name: String
    public var description: String
    public var goal: String
    public var metrics: [Metric]

    init(
        name: String, description: String, goal: String, metrics: [Metric]
    ) {
        self.name = name
        self.description = description
        self.goal = goal
        self.metrics = metrics
    }

}
