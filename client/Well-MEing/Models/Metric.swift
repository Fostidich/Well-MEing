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

    /// The metric object is serialized as a dictionary.
    /// The name field is not included, as the DB object does not contain in, as the name is its key instead.
    /// The ID field is also not included, as it is a redundancy for the name.
    /// Firebase will require the returned dictionary to be casted as a ``NSDictionary``, in order to be uploaded.
    var asDBDict: [String: Any] {
        var dict: [String: Any] = [
            "input": input.rawValue
        ]
        if let description = description {
            dict["description"] = description
        }
        if let config = config {
            dict["config"] = config
        }
        return dict
    }
    
    /// The metric object is serialized as a dictionay.
    /// All fields but the ID are included, with the variable name used as key for its value.
    var asDict: [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "input": input
        ]
        if let description = description {
            dict["description"] = description
        }
        if let config = config {
            dict["config"] = config
        }
        return dict
    }
    
}
