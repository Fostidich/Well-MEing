class Actions {

    public let creations: [Habit]?
    public let loggings: [String: [Submission]]?

    init?(
        creations: [Habit]? = nil,
        loggings: [String: [Submission]]? = nil
    ) {
        let loggings = loggings?.filter { !$0.value.isEmpty }

        self.creations = (creations?.isEmpty ?? true) ? nil : creations
        self.loggings = (loggings?.isEmpty ?? true) ? nil : loggings

        if creations == nil && loggings == nil {
            return nil
        }
    }

    init?(dict: [String: Any]) {
        guard
            let actions = dict["actions"] as? [String: Any],
            let creations = actions["creation"] as? [[String: Any]],
            let loggings = actions["logging"] as? [String: [Any]]
        else {
            return nil
        }

        self.creations = creations.compactMap { Habit(dict: $0) }
        self.loggings = loggings.compactMapValues { array in
            array.compactMap {
                guard let dict = $0 as? [String: Any] else {
                    return nil
                }
                return Submission(dict: dict)
            }
        }
    }

}
