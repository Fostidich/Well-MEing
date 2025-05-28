import SwiftUI

struct ImportRangeFromHealth: View {
    @Binding var actions: Actions?
    @State private var begin: Date = Calendar.current.startOfDay(for: Date())
    @State private var end: Date = Date()
    @State private var showError: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Data range")
                .bold()
                .foregroundColor(.accentColor)
                .font(.title2)

            // Let user select dates range
            picker("From", selection: $begin)
            picker("To", selection: $end)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.2))
        }
        .alert(
            "Unable to import data from Apple Health",
            isPresented: $showError
        ) {
            Button("OK", role: .cancel) {}
        }
        .onAppear(perform: updateActions)
        .onChange(of: begin, updateActions)
        .onChange(of: end, updateActions)
    }

    private func updateActions() {
        let success = HealthSync.healthActions(
            from: begin,
            to: end,
            into: $actions
        )
        if !success { showError = true }
    }

    private func picker(_ text: String, selection: Binding<Date>) -> some View {
        DatePicker(text, selection: selection, in: ...Date())
            .font(.title3)
            .foregroundColor(.primary)
            .datePickerStyle(.compact)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.2))
            }
    }

}
