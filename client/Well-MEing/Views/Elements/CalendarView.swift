import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    let completion: ((Date, Date) -> Void)?

    var body: some View {
        DatePicker(
            "Select a Date",
            selection: $selectedDate,
            in: ...Date(),
            displayedComponents: .date
        )
        .onChange(of: selectedDate, completion ?? { _, _ in })
        .datePickerStyle(.graphical)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
                .padding()
        }
    }
}
