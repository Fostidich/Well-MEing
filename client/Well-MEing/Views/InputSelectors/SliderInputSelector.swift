import SwiftUI

struct SliderInputSelector: View {
    enum Domain: String {
        case min, max
    }

    @Binding var config: [String: Any]
    var resetTrigger: Bool?
    @State private var min: Int?
    @State private var max: Int?
    @State private var float: Bool = false
    @State private var value: Double = 50

    var body: some View {
        Slider(value: $value, in: 0...100, step: 0.01)
            .padding(.bottom)

        // Config stuff selectors
        HStack {
            numberBox($min, .min)
            Spacer()
            toggleButton($float, label: "Decimal")
            Spacer()
            numberBox($max, .max)
        }
        .onChange(of: min) { _, newValue in
            config["min"] = min
            checkRange()
        }
        .onChange(of: max) { _, newValue in
            config["max"] = max
            checkRange()
        }
        .onChange(of: float) { _, newValue in
            config["type"] = float ? "float" : "int"
        }
        .onAppear {
            config["type"] = float ? "float" : "int"
        }
        .onAppear(perform: reset)
        .onChange(of: resetTrigger, reset)
    }
    
    private func reset() {
        value = 50
        min = nil
        max = nil
        float = false
    }

    private func checkRange() {
        var min = config["min"] as? Int ?? 0
        var max = config["max"] as? Int ?? 100

        // Make sure that min is strictly less than max
        if min >= max {
            if min == max {
                max += 50
            } else {
                swap(&min, &max)
            }
        }

        config["min"] = min
        config["max"] = max
    }

    private func numberBox(_ value: Binding<Int?>, _ domain: Domain)
        -> some View
    {
        VStack(spacing: 0) {
            TextField(
                domain.rawValue.capitalized,
                value: value,
                formatter: NumberFormatter()
            )
            .keyboardType(.numberPad)
            .frame(width: 60, height: 30)
            .multilineTextAlignment(domain == .min ? .leading : .trailing)
            Divider()
                .padding(domain == .max ? .leading : .trailing)
        }
        .padding(domain == .max ? .leading : .trailing)
    }

    private func toggleButton(_ isChecked: Binding<Bool>, label: String)
        -> some View
    {
        var color: Color {
            isChecked.wrappedValue ? Color.accentColor : Color.secondary
        }
        return Button(action: {
            isChecked.wrappedValue.toggle()
        }) {
            Text("Decimal")
                .foregroundColor(color)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, style: StrokeStyle(lineWidth: 2))
                        .fill(color.opacity(0.1))
                )
        }
        .padding(.bottom, 2)
    }

}
