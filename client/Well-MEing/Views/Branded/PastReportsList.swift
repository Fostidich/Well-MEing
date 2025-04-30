import SwiftUI

struct PastReportsList: View {
    @State private var selectedReport: Report?
    @State private var toShow: Int = 10
    private let reportsCount: Int = UserCache.shared.reports?.count ?? 0
    var showDeleteAlert: Binding<Bool>?
    var deleteSuccess: Binding<Bool>?
    @ObservedObject var cache = UserCache.shared

    var body: some View {
        // Show reports title
        Text("Reports")
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .padding(.bottom)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)

        VStack(spacing: 8) {
            // List past reports
            ForEach(
                (cache.reports ?? [])
                    .sorted { $0.date > $1.date }
                    .prefix(toShow)
                    .map { $0 }
            ) { report in
                ShowReportButton(
                    report: report,
                    selectedReport: $selectedReport,
                    showDeleteAlert: showDeleteAlert,
                    deleteSuccess: deleteSuccess
                )
            }

            // Button to show older reports
            if toShow < reportsCount {
                Button(action: {
                    toShow += 10
                }) {
                    Text("Load more")
                        .font(.caption)
                        .padding(8)
                        .foregroundColor(Color(.systemBackground))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.accent)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top)
            }
        }
        .padding(.horizontal)
        .sensoryFeedback(.impact(weight: .heavy), trigger: selectedReport?.id)
        .sheet(item: $selectedReport) { report in
            Modal(
                title: "Report of \(report.date.fancyDateString)",
                dismissButton: .done
            ) {
                ShowReportModalContent(report: report)
            }
        }
    }
}

struct ShowReportButton: View {
    let report: Report
    @Binding var selectedReport: Report?
    var showDeleteAlert: Binding<Bool>?
    var deleteSuccess: Binding<Bool>?

    var body: some View {
        Button(action: {
            selectedReport = report
        }) {
            VStack(alignment: .leading) {
                Text(report.title)
                    .bold()
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.accentColor)
                Text(report.date.fancyDateString)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.2))
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            // Show delete button on long press
            Button(role: .destructive) {
                DispatchQueue.main.async {
                    deleteSuccess?.wrappedValue =
                        ReportService.deleteReport(date: report.date)
                    showDeleteAlert?.wrappedValue = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
