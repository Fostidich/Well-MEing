import SwiftUI

struct MetricCreationView: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var inputType: String = ""
    @State private var config: [String: Any] = [:]
    let completion: (Metric) -> Void

    var body: some View {
        // Ask for initial metric information
        VStack(spacing: 4) {
            TextField("Metric name", text: $name)
                .font(.title3)
                .bold()
                .foregroundColor(.accentColor)
            Divider()
                .padding(.bottom)

            TextField("Metric description", text: $description)
            Divider()

            // Ask for which input type to use
            InputTypeSelector(inputType: $inputType, config: $config)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
        )
    }
}

struct InputTypeSelector: View {
    @Binding var inputType: String
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
                        inputType: $inputType,
                        config: $config,
                        item: item
                    )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)
            .onChange(of: currentIndex) { _, newValue in
                if newValue == 0 {
                    currentIndex = count
                } else if newValue == loopingItems.count - 1 {
                    currentIndex = count - 1
                }
                inputType = loopingItems[currentIndex].rawValue
            }
            .onAppear {
                currentIndex = count
                inputType = loopingItems[currentIndex].rawValue
            }

            HStack {
                // Left button
                arrowButton("left") {
                    currentIndex -= 1
                }

                Spacer()

                // Right button
                arrowButton("right") {
                    currentIndex += 1
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
                .font(.title)
        }
        .padding(.vertical)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
        )
    }
}

struct InputTypeSelectorBlock: View {
    @Binding var inputType: String
    @Binding var config: [String: Any]
    let item: InputType

    var body: some View {
        // Show input type name and view
        VStack {
            Text(item.rawValue.capitalized)
                .foregroundColor(.accentColor)
            InputTypeView(input: item, config: nil) { value in }
                .padding()
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
        switch item {
        case .slider:
            InputTypeConfigSelectorSlider()
        case .form:
            InputTypeConfigSelectorForm()
        default:
            EmptyView()
        }
    }
}

struct InputTypeConfigSelectorSlider: View {
    @State private var min: Int?
    @State private var max: Int?
    @State private var float: Bool = false

    var body: some View {
        HStack {
            numberBox($min, label: "Min")
            Spacer()
            checkBox($float, label: "Decimal")
            Spacer()
            numberBox($max, label: "Max")
        }
    }

    private func numberBox(_ value: Binding<Int?>, label: String) -> some View {
        TextField(label, value: value, formatter: NumberFormatter())
            .frame(width: 60, height: 30)
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
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

    var body: some View {
        HStack {
        TextField("New parameter", text: $value)
            .frame(width: 150, height: 30)
            .multilineTextAlignment(.leading)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
        
            Button(action: {
                parameters.append(value)
                value = ""
            }) {
                Text("Add")
            }
        }
    }
}
