import Charts
import SwiftUI

struct ChartsList: View {
    @State private var habitMetrics: [(habit: String, metrics: [String])] = []

    var body: some View {
        VStack(spacing: 16) {
            // Start by iterating over habits
            ForEach(habitMetrics, id: \.habit) { habit, metrics in
                // Display all metrics for the habits
                ChartHabit(habit: habit, metrics: metrics)
            }
        }
        .padding()
        .onAppear {
            habitMetrics =
                UserCache.shared.habits?
                .filter { !($0.metrics?.isEmpty ?? true) }
                .compactMap { habit in
                    let metrics =
                        habit.metrics?
                        .filter {
                            [
                                InputType.slider,
                                InputType.time,
                                InputType.rating,
                            ]
                            .contains($0.input)
                        }
                        .map { $0.name }
                        .sorted() ?? []

                    guard !metrics.isEmpty else { return nil }
                    return (habit.name, metrics)
                }
                .sorted { $0.habit < $1.habit } ?? []
        }
    }

}

struct ChartHabit: View {
    let habit: String
    let metrics: [String]
    @State private var currentMetric: Int = 0
    @State private var weekOffset: Int = 0
    @State private var weekData: [Float] = Array(repeating: 0, count: 7)
    @StateObject private var cache = UserCache.shared

    var body: some View {
        // Display chart
        VStack {
            ChartMetric(
                habit: habit,
                metrics: metrics,
                weekData: $weekData,
                currentMetric: $currentMetric,
                weekOffset: $weekOffset
            )
        }
        .onAppear(perform: updateData)
        .onChange(of: weekOffset, updateData)
        .onChange(of: currentMetric, updateData)
    }

    private func updateData() {
        weekData = HistoryManager.aggregateMetricForWeek(
            habit: habit,
            metric: metrics[currentMetric],
            weekOffset: weekOffset
        )
    }

}

struct ChartMetric: View {
    let habit: String
    let metrics: [String]
    @Binding var weekData: [Float]
    @Binding var currentMetric: Int
    @Binding var weekOffset: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Chart data descriptors
            Text(habit)
                .font(.title3)
                .foregroundColor(.accentColor)
                .bold()
                .padding(.bottom)

            // Buttons to change displayed metric
            HStack(alignment: .center) {
                changeMetric("left", op: -)
                Text(metrics[currentMetric])
                    .bold()
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                changeMetric("right", op: +)
            }

            // Buttons to change displayed week
            HStack(alignment: .center) {
                changeWeek("left", op: -)
                Text(Date.weekRangeString(weekOffset))
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                changeWeek("right", op: +)
            }

            // Actual chart displaying data
            Chart(Array(weekData.enumerated()), id: \.offset) {
                index,
                value in
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
    }

    private func changeMetric(
        _ direction: String,
        op: @escaping (Int, Int) -> Int
    )
        -> some View
    {
        Button(action: {
            currentMetric =
                (op(currentMetric, 1) + metrics.count)
                % metrics.count
        }) {
            Image(systemName: "chevron." + direction)
                .font(.title3)
                .bold()
        }
        .disabled(metrics.count <= 1)
    }

    private func changeWeek(
        _ direction: String,
        op: @escaping (Int, Int) -> Int
    )
        -> some View
    {
        let hidden = direction == "right" && weekOffset >= 0
        return Button(action: {
            weekOffset = op(weekOffset, 1)
        }) {
            Image(systemName: "chevron." + direction)
                .foregroundColor(.secondary)
                .padding()
        }
        .disabled(hidden)
        .opacity(hidden ? 0 : 1)
    }

}
