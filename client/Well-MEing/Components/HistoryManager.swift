import Foundation

/// Old submission must be able to be retrieved in order to be shown, for
/// instance, from the calendar view or in the charts. This component allow for the retrieval of
/// past data, e.g. per-day.
/// The methods in this struct that are used to aggregate data (e.g. to be shown in charts) follow some
/// aggregation functions rules, which are based on the input format: ints, floats and time duration
/// (i.e. sliders and time selectors) are summed, while ratings (stars) are averaged.
struct HistoryManager {

    /// Given a date, the list of all submissions for that day is returned.
    static func retrieveSubmissions(day: Date) -> [Submission] {
        // TODO: define method
        return []
    }
    
    /// The list of all submission of the specified habits for the last 7 days is returned.
    static func retrieveLastWeekSubmissions(habits: [String]) -> [Submission] {
        // TODO: define method
        return []
    }

    /// Given an habit and one of its metric, all its submissions made in the current day are retrieved.
    /// Then, they are aggregated by the hour following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 24 elements, corresponding to the 24 hours of the day.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    static func aggregateSubmissionsByHours(habit: String, metric: String)
        -> [Any]
    {
        // TODO: define method
        return []
    }

    /// Given an habit and one of its metric, all its submissions made in the current month are retrieved.
    /// Then, they are aggregated by the day following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 28-31 elements, corresponding to the days of that month.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    static func aggregateSubmissionsByDay(habit: String, metric: String)
        -> [Int: Any]
    {
        // TODO: define method
        return [:]
    }

    /// Given an habit and one of its metric, all its submissions made in the current year are retrieved.
    /// Then, they are aggregated by the month following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 12 elements, corresponding to the 12 months of the year.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    static func aggregateSubmissionsByMonth(habit: String, metric: String)
        -> [Int: Any]
    {
        // TODO: define method
        return [:]
    }

}
