class Metric: Identifiable {
    var id: String { name }

    public var name: String
    public var description: String?
    public var inputType: InputType
    public var config: [String: Any]?

    init(
        name: String,
        description: String? = nil,
        inputType: InputType,
        config: [String: Any]? = nil
    ) {
        self.name = name
        self.description = description
        self.inputType = inputType
        self.config = config
    }

    init?(dict: [String: Any]) {
        guard
            let name = dict["name"] as? String,
            let inputTypeString = dict["input_type"] as? String,
            let inputType = InputType(rawValue: inputTypeString)
        else {
            return nil
        }

        let description = dict["description"] as? String
        let config = dict["config"] as? [String: Any]

        self.name = name
        self.description = description
        self.inputType = inputType
        self.config = config
    }

}
