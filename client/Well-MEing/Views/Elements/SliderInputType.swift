import SwiftUI

struct SliderInputType: View {
    enum ValueType {
        case int, float
    }

    let completion: (Any?) -> Void

    @State private var min: Double
    @State private var max: Double
    private let type: ValueType

    @State private var _value: Double
    private var value: Any {
        rounded(_value)
    }

    init(
        config: [String: Any]?,
        completion: @escaping (Any) -> Void
    ) {
        self.completion = completion

        // Detect type
        if let t = config?["type"] as? String, t.lowercased() == "int" {
            self.type = .int
        } else {
            self.type = .float
        }

        // Parse min and max as Int or Double
        func parseNumber(_ any: Any?) -> Double? {
            if let d = any as? Double { return d }
            if let i = any as? Int { return Double(i) }
            if let n = any as? NSNumber { return n.doubleValue }
            return nil
        }

        // Parse on a non-self var, as required for another self intialization
        var fixMin = parseNumber(config?["min"]) ?? 0
        var fixMax = parseNumber(config?["max"]) ?? 100
        if fixMin == fixMax {
            fixMax += 50
        } else if fixMin > fixMax {
            (fixMin, fixMax) = (fixMax, fixMin)
        }

        // Initialize last values
        self._value = fixMin + (fixMax - fixMin) / 2
        self.min = fixMin
        self.max = fixMax
    }

    var body: some View {
        VStack {
            // Slider and range increasing buttons
            HStack {
                Button(action: minusButtonTapped) {
                    Image(systemName: "minus")
                }

                Slider(value: $_value, in: min...max, step: 0.01)
                    .padding(.horizontal)
                    .onAppear(perform: {
                        // Slider immediately sets the default value for that metric
                        completion(value)
                    })
                    .onChange(of: _value) {
                        completion(value)
                    }

                Button(action: plusButtonTapped) {
                    Image(systemName: "plus")
                }
            }

            // Selected value and ranges labels
            HStack {
                Text(displayString(for: rounded(min)))
                Spacer()
                Text(displayString(for: value))
                Spacer()
                Text(displayString(for: rounded(max)))
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }

    private func plusButtonTapped() {
        max = max == 0 ? -min : (max > 0 ? max * 2 : 0)
        max = Swift.min(max, 10e6)
    }

    private func minusButtonTapped() {
        min = min == 0 ? -max : (min < 0 ? min * 2 : 0)
        min = Swift.max(min, -10e6)
    }

    private func rounded(_ value: Double) -> Any {
        let roundedValue = round(100 * value) / 100
        switch type {
        case .int:
            return Int(roundedValue)
        case .float:
            return Float(roundedValue)
        }
    }

    private func displayString(for any: Any) -> String {
        if let intVal = any as? Int {
            return String(intVal)
        } else if let floatVal = any as? Float {
            return String(format: "%.2f", floatVal)
        } else {
            return "?"
        }
    }
}
