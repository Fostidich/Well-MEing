import Foundation
import SwiftUI

/// Old submission must be able to be retrieved in order to be shown, for
/// instance, from the calendar view or in the charts. This component allow for the retrieval, pruning
/// and aggregation of past data.
/// The methods in this struct that are used to aggregate data to be shown in charts follow some
/// aggregation functions rules, which are based on the input format: ints, floats and time durations
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
        let oneMonthAgo = Calendar.current.date(
            byAdding: .day, value: -30, to: now)!

        return
            allHabits
            .filter { names?.contains($0.name) ?? true }
            .compactMap { habit in
                let trimmedHistory = habit.history?.filter {
                    $0.timestamp >= oneMonthAgo && $0.timestamp <= now
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

    /// Given an habit and one of its metric, all its submissions made in the current week are retrieved.
    /// Then, they are aggregated by the day following the aggregation functions defined in the ``HistoryManager``.
    /// In the returned list there are 7 elements, corresponding to the days of that week.
    /// - SeeAlso: ``HistoryManager`` defines the aggregation functions for each input format.
    @MainActor static func aggregateMetricForWeek(
        habit: String,
        metric: String,
        weekOffset: Int
    ) -> [Float] {
        // Check there there is data to show
        guard
            let habit = UserCache.shared.habits?.first(where: {
                $0.name == habit
            }),
            let metric = habit.metrics?.first(where: {
                $0.name == metric
            }),
            let history = habit.history
        else { return Array(repeating: 0, count: 7) }

        // List submissions data by week day
        return
            history
            .filter { $0.timestamp.inWeek(weekOffset) }
            .reduce(into: Array(repeating: [Float](), count: 7)) {
                result, record in
                guard let value = record.metrics?[metric.name] else { return }
                let toFloat = metric.input.toFloat
                let index = record.timestamp.weekdayIndex
                result[index].append(toFloat(value))
            }
            .map { values in
                let reduce = metric.input.reduction
                var partial = values.first ?? 0
                values.dropFirst(1).forEach { partial = reduce(partial, $0) }
                return partial
            }
    }

}
