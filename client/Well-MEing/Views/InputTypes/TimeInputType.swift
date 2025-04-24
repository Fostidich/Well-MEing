import SwiftUI

struct TimeInputType: View {
    let config: [String: Any]?
    let completion: (Any?) -> Void
    var initialValue: Any?
    @State private var hour = 0
    @State private var minute = 0
    @State private var second = 0

    var duration: String {
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }

    var body: some View {
        HStack {
            timeUnitSelector(unit: "h", range: 0..<24, selection: $hour)
            timeUnitSelector(unit: "m", range: 0..<60, selection: $minute)
            timeUnitSelector(unit: "s", range: 0..<60, selection: $second)
        }
        .frame(height: 100)
        .offset(y: -20)
        .padding(.bottom, -40)
        .onAppear {
            // Time immediately sets the default value for that metric
            if let initialValue = initialValue as? String {
                // Check if initial value is set
                let components =
                    initialValue
                    .split(separator: ":")
                    .compactMap { Int($0) }
                (hour, minute, second) = {
                    guard components.count == 3 else { return (0, 0, 0) }
                    return (components[0], components[1], components[2])
                }()
            } else {
                completion("00:00:00")
            }
        }
        .onChange(of: duration) { _, newValue in
            completion(duration)
        }
    }

    private func timeUnitSelector(
        unit: String, range: Range<Int>, selection: Binding<Int>
    ) -> some View {
        Picker("", selection: selection) {
            ForEach(range, id: \.self) { value in
                Text("\(value) \(unit)")
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 80)
        .scaleEffect(0.8)
    }

}
