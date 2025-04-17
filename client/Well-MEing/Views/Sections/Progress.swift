import Charts
import SwiftUI

struct Progress: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CalendarView()
            
            // Progress graphs data title
            Text("Summary")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // List all charts
            TowerChartBlock(title: "Steps", data: MockData.chart1, color: .blue)
            TowerChartBlock(title: "Running", data: MockData.chart2)
            TowerChartBlock(title: "Stress", data: MockData.chart3, color: .orange)
        }
    }
}

struct TowerChartBlock: View {
    let title: String
    let data: [(Int, Int)]
    var color: Color = .accentColor

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
                    TowerChart(title: title, data: data, color: color)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding()
    }
}

struct TowerChart: View {
    let title: String
    let data: [(Int, Int)]
    var color: Color
    
    var body: some View {
        Chart(data, id: \.0) { item in
            BarMark(
                x: .value("Day", item.0),
                y: .value("Steps", item.1),
                width: 8
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
}

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var showModal: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Calendar data title
            Text("Past data")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Calendar view
            ZStack {
                // Calendar background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))
                    .padding()

                // Actual days
                DatePicker(
                    "Select a Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .onChange(of: selectedDate) {
                    showModal.toggle()
                }
                .datePickerStyle(GraphicalDatePickerStyle())  // calendar-like view
                .padding(20)
                .sheet(isPresented: $showModal) {
                    PastDataModal(
                        date: selectedDate
                    )
                }
            }
        }
    }
}

struct PastDataModal: View {
    @Environment(\.dismiss) var dismiss
    let date: Date

    var body: some View {
        NavigationStack {
            // Modal content
            VStack(alignment: .leading, spacing: 10) {
                let dayData = MockData.pastData[date.shortString] ?? []
                PastDataContent(content: dayData)
            }
            .navigationBarTitle(
                "Data of " + date.shortString,
                displayMode: .inline
            )  // title in center
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()  // dismiss modal
                }
            )
            .frame(
                maxWidth: .infinity, maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
        }
    }
}

struct PastDataContent: View {
    let content:
        [(
            name: String, color: Color,
            tasks: [(title: String, quantity: Int)]
        )]

    var body: some View {
        if content.isEmpty {
            Text("No data to show")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            // Each data group/tasks listing
            ForEach(content, id: \.name) { item in
                // Group name
                Text(item.name)
                    .font(.title)
                    .padding(.bottom)

                // Tasks list with quantities
                ForEach(item.tasks, id: \.title) { content in
                    Text(content.title + ": ")
                        + Text(String(content.quantity)).foregroundColor(
                            item.color)
                }

                Spacer().frame(height: 25)
            }
        }
    }
}
