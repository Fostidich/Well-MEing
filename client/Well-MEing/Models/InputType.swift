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

}
