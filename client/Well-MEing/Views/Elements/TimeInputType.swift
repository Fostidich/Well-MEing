import SwiftUI

struct TimeInputType: View {
    let completion: (Any?) -> Void
    @State private var time: Date =
        Calendar.current.date(
            from: DateComponents(hour: 0, minute: 0)
        ) ?? Date()

    var body: some View {
        DatePicker(
            "",
            selection: $time,
            displayedComponents: .hourAndMinute
        )
        .labelsHidden()
        .datePickerStyle(.compact)
        .onAppear {
            // Time immediately sets the default value for that metric
            completion("00:00")
        }
        .onChange(of: time) { _, newValue in
            completion(time.timeString)
        }
    }

}
