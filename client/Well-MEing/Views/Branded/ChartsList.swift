import Charts
import SwiftUI

struct ChartsList: View {
    @State private var charts:
        [String: [String: (offset: Int, data: [Float])]] = [:]
    let initialEntry: (offset: Int, data: [Float]) = (
        0, Array(repeating: 0, count: 7)
    )
    @StateObject private var cache = UserCache.shared

    var body: some View {
        VStack(spacing: 16) {
            // Start by iterating over habits
            ForEach(Array(charts.keys.sorted()), id: \.self) { habit in
                // Display all metrics for the habits
                ChartsGroup(
                    habit: habit,
                    charts: $charts,
                    initialEntry: initialEntry
                )
            }
        }
        .padding()
        .onAppear(perform: initCharts)
        .onChange(of: cache.habits?.isEmpty, initCharts)
    }

    private func initCharts() {
        // Create and initial entry in charts only if metric is displayable
        for habit in cache.habits ?? [] {
            for metric in habit.metrics ?? [] {
                guard
                    metric.input == .slider
                        || metric.input == .rating
                        || metric.input == .time
                else { continue }
                let data = HistoryManager.aggregateMetricForWeek(
                    habit: habit.name, metric: metric.name, weekOffset: 0)
                charts[habit.name, default: [:]][metric.name] = (0, data)
            }
        }
    }

}

struct ChartsGroup: View {
    let habit: String
    @Binding var charts: [String: [String: (offset: Int, data: [Float])]]
    let initialEntry: (offset: Int, data: [Float])

    var body: some View {
        if let chartEntry = charts[habit] {
            ForEach(Array(chartEntry.keys.sorted()), id: \.self) { metric in
                // Display chart, minding bindings
                ChartBlock(
                    habit: habit,
                    metric: metric,
                    weekOffset: Binding(
                        get: {
                            charts[habit]?[metric]?.offset
                                ?? initialEntry.offset
                        },
                        set: {
                            var entry =
                                charts[habit]?[metric] ?? initialEntry
                            entry.offset = $0
                            charts[habit]?[metric] = entry
                        }
                    ),
                    weekData: Binding(
                        get: {
                            charts[habit]?[metric]?.data
                                ?? initialEntry.data
                        },
                        set: {
                            var entry =
                                charts[habit]?[metric] ?? initialEntry
                            entry.data = $0
                            charts[habit]?[metric] = entry
                        }
                    )
                )
            }
        }
    }

}

struct ChartBlock: View {
    let habit: String
    let metric: String
    @Binding var weekOffset: Int
    @Binding var weekData: [Float]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Chart data descriptors
            Text(habit)
                .font(.title3)
                .foregroundColor(.accentColor)
                .bold()
            Text(metric)
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .bold()

            // Buttons to change displayed week
            HStack(alignment: .center, spacing: 20) {
                arrowButton("left", op: -)
                Text(Date.weekRangeString(weekOffset))
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                arrowButton("right", op: +)
            }

            // Actual chart displaying data
            Chart(Array(weekData.enumerated()), id: \.offset) {
                index, value in
                BarMark(
                    x: .value("Day", Date.weekDayString(index)),
                    y: .value("Value", value),
                    width: 25
                )
            }
            .frame(height: 200)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
        .onChange(of: weekOffset) {
            weekData = HistoryManager.aggregateMetricForWeek(
                habit: habit, metric: metric, weekOffset: weekOffset
            )
        }
    }

    private func arrowButton(
        _ direction: String, op: @escaping (Int, Int) -> Int
    )
        -> some View
    {
        Button(action: {
            weekOffset = op(weekOffset, 1)
        }) {
            Image(systemName: "chevron." + direction)
                .font(.title3)
                .bold()
                .padding()
        }
    }

}
