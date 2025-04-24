import SwiftUI

struct FormInputSelector: View {
    @Binding var config: [String: Any]
    var resetTrigger: Bool?
    @State private var value: String = ""
    @State private var parameters: [String] = []
    @State private var checked: [Bool] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Inserted fields
            ForEach(Array(parameters.enumerated()), id: \.offset) {
                index, box in
                HStack {
                    CheckBox(isChecked: $checked[index], label: box)
                    Button(action: {
                        parameters.remove(at: index)
                        checked.remove(at: index)
                        config["boxes"] = parameters
                    }) {
                        Image(systemName: "multiply")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.accentColor)
                    }
                }
            }

            // Config stuff selectors
            HStack {
                Button(action: addParameter) {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 2)
                }
                TextField("New parameter", text: $value)
                    .submitLabel(.done)
                    .frame(width: 150, height: 20)
                    .multilineTextAlignment(.leading)
                    .onSubmit(addParameter)
                Spacer()
            }
        }
        .onAppear(perform: assign)
        .onChange(of: resetTrigger, reset)
    }
    
    private func reset() {
        value = ""
        parameters = []
        checked = []
    }

    private func assign() {
        value = ""
        parameters = config["boxes"] as? [String] ?? []
        checked = Array(repeating: false, count: parameters.count)
    }
    
    private func addParameter() {
        if value.isEmpty || parameters.count >= 10 { return }
        parameters.append(value)
        checked.append(false)
        config["boxes"] = parameters
        value = ""
    }

}
