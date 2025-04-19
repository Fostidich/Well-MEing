import SwiftUI

struct MetricCreationView: View {
    @Binding var metric: [String: Any]
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var inputType: InputType = .slider
    @State private var config: [String: Any] = [:]

    var body: some View {
        // Ask for initial metric information
        VStack(spacing: 4) {
            TextField("Metric name", text: $name)
                .submitLabel(.done)
                .font(.title3)
                .bold()
                .foregroundColor(.accentColor)
            Divider()
                .padding(.bottom)

            TextField("Metric description", text: $description)
                .submitLabel(.done)
            Divider()

            // Ask for which input type to use
            InputTypeSelector(inputType: $inputType, config: $config)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
        )
        .onAppear {
            name = metric["name"] as? String ?? ""
            description = metric["description"] as? String ?? ""
            inputType = metric["input"] as? InputType ?? .slider
            config = metric["config"] as? [String: Any] ?? [:]
        }
        .onChange(of: name) {
            metric["name"] = name
        }
        .onChange(of: description) {
            metric["description"] = description
        }
        .onChange(of: inputType) {
            metric["input"] = inputType
        }
        .onChange(of: config.mapValues { "\($0)" }) {
            metric["config"] = config
        }
    }
}

struct InputTypeSelector: View {
    @Binding var inputType: InputType
    @Binding var config: [String: Any]
    @State private var currentIndex = 0
    let count = InputType.allCases.count

    private var loopingItems: [InputType] {
        InputType.allCases + InputType.allCases + InputType.allCases
    }

    var body: some View {
        ZStack {
            // Horizontal scroll for input type selection
            TabView(selection: $currentIndex) {
                ForEach(Array(loopingItems.enumerated()), id: \.offset) {
                    index, item in
                    InputTypeSelectorBlock(
                        inputType: item,
                        config: $config
                    )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 220)
            .onChange(of: currentIndex) { _, newValue in
                // Move to following element
                if newValue == 0 {
                    currentIndex = count
                } else if newValue == loopingItems.count - 1 {
                    currentIndex = count - 1
                }

                // Update selected input type
                inputType = loopingItems[currentIndex]

                // Reset config dict
                config = [:]
            }
            .onAppear {
                currentIndex = count
                inputType = loopingItems[currentIndex]
                config = [:]
            }

            // Arrow buttons
            HStack {
                arrowButton("left") {
                    if currentIndex > 0 {
                        currentIndex -= 1
                    }
                }

                Spacer()

                arrowButton("right") {
                    if currentIndex < loopingItems.count - 1 {
                        currentIndex += 1
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical)
    }

    private func arrowButton(_ direction: String, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            Image(systemName: "chevron.compact." + direction)
                .padding(.vertical)
                .padding(.horizontal, 4)
                .font(.title)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.20))
                )
        }
    }
}

struct InputTypeSelectorBlock: View {
    let inputType: InputType
    @Binding var config: [String: Any]

    var body: some View {
        // Show input type name and view
        VStack {
            Text(inputType.rawValue.capitalized)
                .foregroundColor(.accentColor)
            InputTypeView(input: inputType, config: config) { value in }
                .padding()
            Divider()
            Spacer()
            inputTypeConfigSelector
        }
        .padding()
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
        )
    }

    @ViewBuilder
    private var inputTypeConfigSelector: some View {
        switch inputType {
        case .slider:
            InputTypeConfigSelectorSlider(config: $config)
        case .form:
            InputTypeConfigSelectorForm(config: $config)
        default:
            EmptyView()
        }
    }
}

struct InputTypeConfigSelectorSlider: View {
    @State private var min: Int?
    @State private var max: Int?
    @State private var float: Bool = false
    @FocusState private var isFocused: Bool
    @Binding var config: [String: Any]

    var body: some View {
        HStack {
            numberBox($min, label: "Min")
            Spacer()
            checkBox($float, label: "Decimal")
            Spacer()
            numberBox($max, label: "Max")
        }
        .onChange(of: min) { _, newValue in
            config["min"] = min
        }
        .onChange(of: max) { _, newValue in
            config["max"] = max
        }
        .onChange(of: float) { _, newValue in
            config["type"] = float ? "float" : "int"
        }
    }

    private func numberBox(_ value: Binding<Int?>, label: String) -> some View {
        TextField(label, value: value, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .focused($isFocused)
            .frame(width: 60, height: 30)
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
    }

    private func checkBox(_ isChecked: Binding<Bool>, label: String)
        -> some View
    {
        Button(action: {
            isChecked.wrappedValue.toggle()
        }) {
            VStack(alignment: .center) {
                Text(label)
                    .foregroundColor(.primary)
                    .padding(.bottom, 2)
                Image(
                    systemName: isChecked.wrappedValue
                        ? "checkmark.square" : "square"
                )
                .foregroundColor(.accentColor)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct InputTypeConfigSelectorForm: View {
    @State private var value: String = ""
    @State private var parameters: [String] = []
    @Binding var config: [String: Any]

    var body: some View {
        TextField("New parameter", text: $value)
            .submitLabel(.done)
            .frame(width: 150, height: 30)
            .multilineTextAlignment(.leading)
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                if value.isEmpty { return }
                parameters.append(value)
                config["boxes"] = parameters
                value = ""
            }
    }
}
