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
    @State var onAppearSkips: Bool = true
    @State var onChangeSkips: Bool = true
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
                    InputSelectorView(
                        input: item,
                        config: $config,
                        resetTrigger: (currentIndex != index)
                    )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)

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
        .onChange(of: currentIndex) { _, newValue in
            // Move to following element
            if newValue == 0 {
                currentIndex = count
            } else if newValue == loopingItems.count - 1 {
                currentIndex = count - 1
            }

            // Update selected input type
            inputType = loopingItems[currentIndex]

            // Reset config dict, but the first time metric views appear
            if onChangeSkips {
                onChangeSkips = false
            } else {
                config = [:]
            }
        }
        .onAppear {
            // Set first input type
            currentIndex =
                count + (InputType.allCases.firstIndex(of: inputType) ?? 0)
            inputType = loopingItems[currentIndex]

            // Reset config dict, but the first time metric views appear
            if onAppearSkips {
                onAppearSkips = false
            } else {
                config = [:]
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
                .contentShape(Rectangle())
        }
    }
}
