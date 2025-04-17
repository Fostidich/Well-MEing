import SwiftUI

struct TimeInputType: View {
    let completion: (Any?) -> Void
    @State private var hour = 0
    @State private var minute = 0
    @State private var second = 0
    
    var duration: String {
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }

    var body: some View {
        HStack {
            TimeUnitPicker(unit: "h", range: 0..<24, selection: $hour)
            TimeUnitPicker(unit: "m", range: 0..<60, selection: $minute)
            TimeUnitPicker(unit: "s", range: 0..<60, selection: $second)
        }
        .frame(height: 100)
        .offset(y: -20)
        .padding(.bottom, -40)
        .onAppear {
            // Time immediately sets the default value for that metric
            completion("00:00:00")
        }
        .onChange(of: duration) { _, newValue in
            completion(duration)
        }
    }

}

struct TimeUnitPicker: View {
    let unit: String
    let range: Range<Int>
    @Binding var selection: Int

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(range, id: \.self) { value in
                Text("\(value) \(unit)")
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 80)
        .scaleEffect(0.8)
    }
}
