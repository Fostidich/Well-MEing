/// Each input type may require a set of configuration values.
/// This config dictionary can be found in the doc of each enum value.
enum InputType: String, CaseIterable, Identifiable {

    var id: String { rawValue }

    /// Sliders require the following configuration values.
    /// ```json
    /// "config": {
    ///     "type": "int/float",
    ///     "min": 0,
    ///     "max": 10
    /// }
    /// ```
    /// Insertions require the following format.
    /// ```json
    /// {
    ///     "Metric 1": "0",
    ///     "Metric 2": "-10",
    ///     "Metric 3": "12.34",
    /// }
    /// ```
    case slider = "slider"

    /// Text fields do not require any configuration values.
    /// ```json
    /// "config": {
    /// }
    /// ```
    /// Insertions require the following format.
    /// ```json
    /// {
    ///     "Metric 1": "Text example",
    /// }
    /// ```
    case text = "text"

    /// Multi-box forms require the following configuration values.
    /// ```json
    /// "config": {
    ///     "boxes": [
    ///         "first-value-name",
    ///         "second-value-name",
    ///         "third-value-name"
    ///     ]
    /// }
    /// ```
    /// Insertions require the following format.
    /// ```json
    /// {
    ///     "Metric 1": "",
    ///     "Metric 2": "param1;param2"
    /// }
    /// ```
    case form = "form"

    /// Time selectors do not require any configuration values.
    /// ```json
    /// "config": {
    /// }
    /// ```
    /// Insertions require the following format.
    /// ```json
    /// {
    ///     "Metric 1": "01:45:30",
    /// }
    /// ```
    case time = "time"

    /// Star ratings do not require any configuration values.
    /// ```json
    /// "config": {
    /// }
    /// ```
    /// Insertions require the following format.
    /// ```json
    /// {
    ///     "Metric 1": "1",
    ///     "Metric 2": "5",
    /// }
    /// ```
    case rating = "rating"

    var reduction: (Float, Float) -> Float {
        switch self {
        case .slider:
            return (+)
        case .rating:
            var count: Float = 1
            return {
                count += 1
                return ($0 * (count - 1) + $1) / count
            }
        case .time:
            return (+)
        case .text, .form:
            return { _, _ in return 0 }
        }
    }

    func toFloat(_ value: Any) -> Float {
        if self == .time { return parseTime(value) }
        switch value {
        case let v as Int: return Float(v)
        case let v as Float: return v
        case let v as Double: return Float(v)
        default: return 0
        }
    }

    private func parseTime(_ value: Any) -> Float {
        guard
            let components =
                (value as? String)?
                .split(separator: ":")
                .compactMap({ Float($0) }),
            components.count == 3
        else { return 0 }
        let (hour, minute, second) = (
            components[0], components[1], components[2]
        )
        return 60 * hour + minute + second / 60
    }

}
