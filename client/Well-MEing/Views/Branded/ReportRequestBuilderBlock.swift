import SwiftUI

struct ReportRequestBuilderBlock: View {
    @Environment(\.dismiss) var dismiss
    @State private var newReport: Report?
    @State private var tapped: Bool = false
    @State private var showError: Bool = false
    @State private var checked: [Bool] = []
    @State private var habitNames: [String] = []
    @State private var newReportDate: Date?

    var noneSelected: Bool {
        checked.allSatisfy { !$0 }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Block title
            Text("Request report")
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Explain data adoperation
            Text(
                "The submissions history of the last month of the selected habits will be used to generate the report."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Checked boxes for selecting habits
            VStack(spacing: 0) {
                ForEach(
                    Array(habitNames.enumerated()),
                    id: \.offset
                ) { index, habitName in
                    CheckBox(isChecked: $checked[index], label: habitName)
                }
            }
            .padding(.horizontal)

            // Show message that at least one habit is required if none is
            if habitNames.isEmpty {
                Text("No habit or submissions to request report for")
                    .font(.caption2)
                    .foregroundColor(.red)
            } else if noneSelected {
                Text("Select at least one habit")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            // Show save button
            HButton(
                text: "Request",
                textColor: Color(.systemBackground),
                backgroundColor: .accentColor
            ) {
                tapped = true

                // Defer action to next runloop so UI can update first
                Task {
                    // Request report from backend
                    let request = Request.generateReport(
                        habitNames: selected
                    )
                    let (success, json) = await request.call()

                    // Set states accordingly
                    if success, let json = json {
                        newReport = Report(dict: json)
                    } else {
                        showError = true
                    }
                    tapped = false
                }
            }
            .disabled(tapped || noneSelected || newReportDate != nil)
            .frame(width: 120)

            // Show report availability timestamp
            if let newReportDate = newReportDate {
                Text(
                    "New report request available on \(newReportDate.fancyDateString)"
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: showError)
        .sensoryFeedback(.impact(weight: .heavy), trigger: newReport?.id)
        .alert("Failed to request report", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
        .padding(.bottom)
        .onAppear(perform: updateStates)
        .onChange(of: UserCache.shared.newReportDate, updateStates)
        .sheet(item: $newReport) { report in
            return Modal(title: "New report", dismissButton: .done) {
                ShowReportModalContent(report: report)
            }
        }
    }

    func updateStates() {
        // Check new report date (nil means elapsed)
        let userReportDate = UserCache.shared.newReportDate
        if let userReportDate = userReportDate {
            newReportDate = userReportDate < Date() ? nil : userReportDate
        }

        // Initialize states
        habitNames =
            UserCache.shared.habits?.compactMap {
                guard $0.submissionsCount > 0 else { return nil }
                return $0.name
            } ?? []
        checked = Array(repeating: true, count: habitNames.count)
    }

    var selected: [String] {
        return zip(checked, habitNames).compactMap { isSelected, value in
            isSelected ? value : nil
        }
    }

}
