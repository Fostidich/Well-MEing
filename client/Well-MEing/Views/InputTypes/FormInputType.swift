import SwiftUI

struct FormInputType: View {
    let completion: (Any?) -> Void
    let boxes: [String]
    @State private var checked: [Bool]

    init(
        config: [String: Any]? = nil,
        completion: @escaping (Any?) -> Void
    ) {
        // Check configs and set fallback
        self.boxes = (config?["boxes"] as? [String] ?? ["Done"]).map {
            $0.replacingOccurrences(of: ";", with: "_")
        }
        self.checked = Array(repeating: false, count: boxes.count)
        self.completion = completion
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
