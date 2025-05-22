class Actions: Deserializable {

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

    required init?(dict: [String: Any]) {
        let creations = dict["creation"] as? [String: [String: Any]]
        let loggings = dict["logging"] as? [String: [[String: Any]]]

        guard
            creations != nil || loggings != nil
        else {
            return nil
        }
        
        self.creations = creations?.compactMap { (key, value) in
            if value.isEmpty { return nil }
            var habitData = value
            habitData["name"] = key
            return Habit(dict: habitData)
        }
        self.loggings = loggings?.compactMapValues { array in
            array.isEmpty
                ? nil
                : array.compactMap {
                    $0.isEmpty ? nil : Submission(dict: $0)
                }
        }
    }

}
