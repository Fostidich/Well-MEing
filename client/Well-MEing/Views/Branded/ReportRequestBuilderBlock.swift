import SwiftUI

struct ReportRequestBuilderBlock: View {
    @Environment(\.dismiss) var dismiss
    @State private var newReport: Report?
    @State private var tapped: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String?
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
                Text("No habit to request report for")
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
                    // Request newly generated report
                    var success = await ReportService.getNewReport(
                        habits: selected, report: $newReport)
                    if !success {
                        errorMessage = "Failed to request report"
                    }

                    if success, let newReport = newReport {
                        success = ReportService.uploadReport(
                            report: newReport)
                        if !success {
                            errorMessage =
                                "Unable to upload newly generated report"
                        }
                    }

                    if !success { showError = true }
                    tapped = false
                }
            }
            .disabled(tapped || noneSelected || newReportDate != nil)
            .frame(width: 120)

            // Show report availability timestamp
            if let newReportDate = newReportDate {
                Text(
                    "New report request available on \(newReportDate.fancyString)"
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .alert(errorMessage ?? "Unknown error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
        .padding(.bottom)
        .onAppear {
            // Check new report date (nil means elapsed)
            let userReportDate = UserCache.shared.newReportDate
            if let userReportDate = userReportDate {
                newReportDate = userReportDate < Date() ? nil : userReportDate
            }

            // Initialize states
            habitNames = UserCache.shared.habits?.compactMap { $0.name } ?? []
            checked = Array(repeating: true, count: habitNames.count)
        }
        .sheet(item: $newReport) { report in
            Modal(title: "New report", dismissButton: .done) {
                ShowReportModalContent(report: report)
            }
        }
    }

    var selected: [String] {
        return zip(checked, habitNames).compactMap { isSelected, value in
            isSelected ? value : nil
        }
    }

}
