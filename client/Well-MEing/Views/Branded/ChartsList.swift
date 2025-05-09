// commit 2:
import Charts
import SwiftUI

// MARK: - Models

struct ChartItem: Hashable {
    let habitName: String
    let metricName: String
}

struct DayValue: Identifiable {
    let id = UUID()
    let date: Date
    let value: Float
}

// MARK: - Main View

struct ChartsList: View {
    @State private var chartsList: [ChartItem]?
    @State private var charts:
        [String: [String: (weeksBehind: Int, chart: [Float])]] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(chartsList ?? [], id: \.self) { item in
                    ChartBlock(
                        item: item,
                        weekOffset: Binding(
                            get: {
                                charts[item.habitName]?[item.metricName]?
                                    .weeksBehind ?? 0
                            },
                            set: { newValue in
                                charts[item.habitName]?[item.metricName]?
                                    .weeksBehind = newValue
                            }
                        ),
                        currentWeekData: Binding(
                            get: {
                                charts[item.habitName]?[item.metricName]?.chart
                                    ?? []
                            },
                            set: { newValue in
                                charts[item.habitName]?[item.metricName]?
                                    .chart = newValue
                            }
                        )
                    )
                }
            }
            .padding()
        }
        .onAppear {
            let habits = UserCache.shared.habits ?? []
            chartsList = generateChartsList(from: habits)
            var result: [String: [String: (weeksBehind: Int, chart: [Float])]] =
                [:]
            for item in chartsList ?? [] {
                // kello function
                let chart: [Float] = [1, 2, 3, 4, 5, 6, 7]
                let wb = 0
                if result[item.habitName] == nil {
                    result[item.habitName] = [:]
                }
                result[item.habitName]?[item.metricName] = (
                    weeksBehind: wb, chart: chart
                )
            }

            charts = result
        }
    }
}

// MARK: - Subview: ChartBlock

struct ChartBlock: View {
    let item: ChartItem
    @Binding var weekOffset: Int
    @Binding var currentWeekData: [Float]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habit: \(item.habitName)")
                .font(.headline)

            Text("Metric: \(item.metricName)")
                .font(.subheadline)

            Text("Week: \(currentWeekDateRange(offset: weekOffset))")
                .font(.subheadline)
                .foregroundColor(.gray)

            Chart {
                ForEach(generateDayValues(from: currentWeekData)) { dayValue in
                    BarMark(
                        x: .value(
                            "Day", weekdayFormatter.string(from: dayValue.date)),
                        y: .value("Value", dayValue.value)
                    )
                }
            }
            .frame(height: 150)
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.width > 50 {
                        weekOffset -= 1
                        // kello function
                        currentWeekData = generateRandomWeekValues()
                    } else if value.translation.width < -50 {
                        weekOffset += 1
                        // kello function
                        currentWeekData = generateRandomWeekValues()
                    }
                }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Utilities

private func generateChartsList(from habits: [Habit]) -> [ChartItem] {
    var result: [ChartItem] = []

    for habit in habits {
        let habitName = habit.name
        let metrics = habit.metrics ?? []

        for metric in metrics {
            guard
                metric.input == .slider || metric.input == .rating
                    || metric.input == .time
            else { continue }
            result.append(
                ChartItem(habitName: habitName, metricName: metric.name))
        }
    }
    return result
}

private func generateRandomWeekValues() -> [Float] {
    (0..<7).map { _ in Float.random(in: 1...10) }
}

private func generateDayValues(from values: [Float]) -> [DayValue] {
    let calendar = Calendar.current
    let today = Date()
    guard
        let startOfWeek = calendar.date(
            from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear], from: today))
    else {
        return []
    }
    let monday = calendar.date(byAdding: .day, value: -7, to: startOfWeek)!
    return values.enumerated().compactMap { index, value in
        guard let date = calendar.date(byAdding: .day, value: index, to: monday)
        else { return nil }
        return DayValue(date: date, value: value)
    }
}

private func currentWeekDateRange(offset: Int) -> String {
    var calendar = Calendar.current
    calendar.firstWeekday = 2  // Monday
    let today = Date()
    guard
        let baseWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?
            .start,
        let weekStart = calendar.date(
            byAdding: .day, value: 7 * offset, to: baseWeekStart)
    else { return "" }

    let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateFormat = "d MMM"
    return
        "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
}

private let weekdayFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale.current
    df.dateFormat = "E"
    return df
}()
