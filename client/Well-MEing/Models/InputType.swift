/// Each input type may require a set of configuration values.
/// This config dictionary can be found in the doc of each enum value.
enum InputType: String, CaseIterable {

    /// Sliders require the following configuration values.
    /// ```json
    /// "config": {
    ///     "type": "int/float",
    ///     "min": 0,
    ///     "max": 10
    /// }
    /// ```
    case slider = "slider"

    /// Text fields do not require any configuration values.
    /// ```json
    /// "config": {
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
    case form = "form"

    /// Time selectors do not require any configuration values.
    /// ```json
    /// "config": {
    /// }
    /// ```
    case time = "time"

    /// Star ratings do not require any configuration values.
    /// ```json
    /// "config": {
    /// }
    /// ```
    case rating = "rating"

}
