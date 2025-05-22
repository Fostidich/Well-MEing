import SwiftUI

struct FormInputType: View {
    let completion: (Any?) -> Void
    let boxes: [String]
    @State private var checked: [Bool]

    init(
        config: [String: Any]? = nil,
        completion: @escaping (Any?) -> Void,
        initialValue: Any? = nil
    ) {
        self.completion = completion

        // Check configs and set fallback
        self.boxes = (config?["boxes"] as? [String] ?? ["Done"]).map {
            $0.replacingOccurrences(of: ";", with: "_")
        }

        // Set initial value empty, if not set
        var fixChecked: [Bool] = Array(repeating: false, count: boxes.count)

        if let initialValue = initialValue as? String {
            let selected = NSCountedSet(
                array: initialValue.split(separator: ";").map { String($0) })

            // Boxes are turned true only if that parameter is still found in initial value
            fixChecked = boxes.map { box in
                if selected.count(for: box) > 0 {
                    selected.remove(box)
                    return true
                } else {
                    return false
                }
            }
        }

        self.checked = fixChecked
    }

    var body: some View {
        // List all checkboxes, one for each listed box
        VStack {
            ForEach(Array(boxes.enumerated()), id: \.offset) { index, box in
                CheckBox(isChecked: $checked[index], label: box)
            }
            .onAppear {
                // Form immediately sets the default value for that metric
                completion("")
            }
            .onChange(of: checked) {
                completion(selected.joined(separator: ";"))
            }
        }
    }

    var selected: [String] {
        return zip(checked, boxes).compactMap { isSelected, value in
            isSelected ? value : nil
        }
    }

}
