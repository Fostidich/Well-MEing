import Foundation

/// Old submission must be able to be retrieved in order to be shown, for
/// instance, from the calendar view or in the charts. This component allow for the retrieval of
/// past data, e.g. per-day.
/// The methods in this struct that are used to aggregate data (e.g. to be shown in charts) follow some
/// aggregation functions rules, which are based on the input format: ints, floats and time duration
/// (i.e. sliders and time selectors) are summed, while ratings (stars) are averaged.
struct HistoryManager {

    /// Given a date, the list of all submissions, for each habit, for that day is returned.
    @MainActor static func retrieveSubmissions(day: Date) -> [(
        Habit, Submission
    )] {
        // TODO: is this method good?
        return (UserCache.shared.habits ?? [])
            .flatMap { habit in
                habit.getSubmissions(day: day).map { submission in
                    (habit, submission)
                }
            }
            .sorted { $0.1.timestamp > $1.1.timestamp }
    }

    /// The list of habits with the histories trimmed for the last week is returned.
    static func habitsWithLastWeekSubmissions(habits: [String]) -> [Habit] {
        // TODO: define method
        return []
    }

    /// The list of habits with the histories trimmed for the last month is returned.
    static func habitsWithLastMonthSubmissions(habits: [String]) -> [Submission] {
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
