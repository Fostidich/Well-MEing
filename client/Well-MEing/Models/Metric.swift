class Metric {
    
    public var name: String
    public var description: String
    public var inputType: InputType
    public var config: [String: Any]

    init(
        name: String, description: String, inputType: InputType,
        config: [String: Any]
    ) {
        self.name = name
        self.description = description
        self.inputType = inputType
        self.config = config
    }

}
