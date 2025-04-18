import Foundation

class Metric: Identifiable {
    var id: String { name }

    public let name: String
    public let description: String?
    public let input: InputType
    public let config: [String: Any]?

    init?(
        name: String,
        description: String? = nil,
        input: InputType = .slider,
        config: [String: Any]? = nil
    ) {
        guard let name = name.clean?.prefix(50) else {
            return nil
        }
        self.name = String(name)
        self.description = description.clean.map { String($0.prefix(500)) }
        self.input = input
        self.config = (config?.isEmpty ?? true) ? nil : config
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

        self.name = String(name.prefix(50))
        self.description = description.clean.map { String($0.prefix(500)) }
        self.input = input
        self.config = (config?.isEmpty ?? true) ? nil : config
    }

}
