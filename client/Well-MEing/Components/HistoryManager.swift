import Foundation

/// Old submission must be able to be retrieved in order to be shown, for
/// instance, from the calendar view or in the charts. This component allow for the retrieval of
/// past data, e.g. per-day.
/// The methods in this struct that are used to aggregate data (e.g. to be shown in charts) follow some
/// aggregation functions rules, which are based on the input format: ints, floats and time duration
/// (i.e. sliders and time selectors) are summed, while ratings (stars) are averaged.
struct HistoryManager {

    /// The list of habits with the histories trimmed for the last week is returned.
    @MainActor static func habitsWithLastWeekSubmissions(
        habits names: [String]? = nil
    )
        -> [Habit]
    {
        guard let allHabits = UserCache.shared.habits else { return [] }
        let now = Date()
        let oneWeekAgo = Calendar.current.date(
            byAdding: .day, value: -7, to: now)!

        return
            allHabits
            .filter { names?.contains($0.name) ?? true }
            .compactMap { habit in
                let trimmedHistory = habit.history?.filter {
                    $0.timestamp >= oneWeekAgo && $0.timestamp <= now
                }
                return Habit(
                    name: habit.name,
                    description: habit.description,
                    goal: habit.goal,
                    metrics: habit.metrics,
                    history: trimmedHistory
                )
            }
    }

    /// The list of habits with the histories trimmed for the last month is returned.
    @MainActor static func habitsWithLastMonthSubmissions(
        habits names: [String]? = nil
    ) -> [Habit] {
        guard let allHabits = UserCache.shared.habits else { return [] }
        let now = Date()
        let oneWeekAgo = Calendar.current.date(
            byAdding: .day, value: -30, to: now)!

        return
            allHabits
            .filter { names?.contains($0.name) ?? true }
            .compactMap { habit in
                let trimmedHistory = habit.history?.filter {
                    $0.timestamp >= oneWeekAgo && $0.timestamp <= now
                }
                return Habit(
                    name: habit.name,
                    description: habit.description,
                    goal: habit.goal,
                    metrics: habit.metrics,
                    history: trimmedHistory
                )
            }
    }

    /// Given an habit and one of its metric, all its submissions made in the current day are retrieved.
    /// Then, they are aggregated by the hour following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 24 elements, corresponding to the 24 hours of the day.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    static func aggregateSubmissionsByHours(habit: String, metric: String)
        -> [Int]
    {
        // TODO: define method
        return []
    }

    /// Given an habit and one of its metric, all its submissions made in the current month are retrieved.
    /// Then, they are aggregated by the day following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 28-31 elements, corresponding to the days of that month.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    @MainActor
    static func aggregateSubmissionsByDay(
        habit: String, metric: String
    )
        -> [Any]
    {
        // list to return
        struct DayEntry {
            let date: Date
            let value: Double
        }
        var dayList: [DayEntry] = []
        
       
        

        
        
        

        // return (Date, Double)
        return []
    }

    /// Given an habit and one of its metric, all its submissions made in the current year are retrieved.
    /// Then, they are aggregated by the month following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 12 elements, corresponding to the 12 months of the year.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    static func aggregateSubmissionsByMonth(habit: String, metric: String)
        -> [Any]
    {
        // TODO: define method
        return []
    }

}
