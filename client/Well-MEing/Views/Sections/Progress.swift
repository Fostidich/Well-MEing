import Charts
import SwiftUI

struct Progress: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Progress graphs data title
            Text("Summary")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // List all charts
            TowerChart(title: "Steps", data: MockData.chart1, color: .blue)
            TowerChart(title: "Running", data: MockData.chart2)
            TowerChart(title: "Stress", data: MockData.chart3, color: .orange)
        }
    }
}

struct TowerChart: View {
    let title: String
    let data: [(Int, Int)]
    var color: Color = .accent

    var body: some View {
        ZStack {
            // Chart background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
            
            VStack {
                // Chart title
                Text(title)
                    .font(.title3)
                    .foregroundColor(color)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Actual chart, with the possibility to horizontally scroll
                ScrollView(.horizontal) {
                    Chart(data, id: \.0) { item in
                        BarMark(
                            x: .value("Day", item.0),
                            y: .value("Steps", item.1)
                        )
                        .foregroundStyle(color)
                    }
                    .frame(height: 200)
                    .frame(minWidth: UIScreen.main.bounds.width)
                    .chartXScale(domain: 0...(data.count + 1))
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding()
    }
}
