import Foundation

class Metric: Identifiable {
    var id: String { name }

    public let name: String
    public let description: String?
    public let input: InputType
    public let config: [String: Any]?

    init(
        name: String,
        description: String? = nil,
        input: InputType,
        config: [String: Any]? = nil
    ) {
        self.name = name
        self.description = description.clean
        self.input = input
        self.config = config
    }

    init?(dict: [String: Any]) {
        guard
            let name = dict["name"] as? String,
            let inputString = dict["input"] as? String,
            let input = InputType(rawValue: inputString)
        else {
            return nil
        }

        let description = dict["description"] as? String
        let config = dict["config"] as? [String: Any]

        self.name = name
        self.description = description.clean
        self.input = input
        self.config = config
    }

}
