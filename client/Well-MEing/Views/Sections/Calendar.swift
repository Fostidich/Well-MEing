import SwiftUI

struct Calendar: View {
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
                let dayData = MockData.pastData[serializeShortDate(date: date)] ?? []
                PastDataContent(content: dayData)
            }
            .navigationBarTitle(
                "Data of " + serializeShortDate(date: date),
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
                    + Text(String(content.quantity)).foregroundColor(item.color)
                }
                
                Spacer().frame(height: 25)
            }
        }
    }
}
