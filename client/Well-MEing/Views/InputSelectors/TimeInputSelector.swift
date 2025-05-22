import SwiftUI

struct TimeInputSelector: View {
    @Binding var config: [String: Any]
    var resetTrigger: Bool?
    @State private var hour = 0
    @State private var minute = 0
    @State private var second = 0

    var body: some View {
        HStack {
            timeUnitSelector(unit: "h", range: 0..<24, selection: $hour)
            timeUnitSelector(unit: "m", range: 0..<60, selection: $minute)
            timeUnitSelector(unit: "s", range: 0..<60, selection: $second)
        }
        .frame(height: 100)
        .offset(y: -20)
        .padding(.bottom, -40)
        .onAppear(perform: reset)
        .onChange(of: resetTrigger, reset)
    }
    
    private func reset() {
        hour = 0
        minute = 0
        second = 0
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
