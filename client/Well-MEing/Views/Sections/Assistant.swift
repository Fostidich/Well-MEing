import Foundation
import SwiftUI

struct Assistant: View {
    @State private var showDeleteAlert = false
    @State private var deleteSuccess = false

    var body: some View {
        // TODO: add haptics
        
        // Generate report button
        RequestReportButton()

        // Show past reports list
        PastReportsList(
            showDeleteAlert: $showDeleteAlert,
            deleteSuccess: $deleteSuccess
        )
            .alert(
                deleteSuccess
                    ? "Report deleted successfully" : "Failed to delete report",
                isPresented: $showDeleteAlert
            ) {
                Button("OK", role: .cancel) {}
            }
    }

}

struct RequestReportButton: View {
    var body: some View {
        NavigationLink {
            ReportRequestPageContent()
                .navigationTitle("Ask for a report")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.accentColor)
                    .padding(.horizontal)
                Text("Request report")
                    .foregroundColor(.accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.accentColor)
            }
            .bold()
            .font(.title3)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.2))
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

struct PastReportsList: View {
    @State private var selectedReport: Report?
    @State private var toShow: Int = 10
    private let reportsCount: Int = UserCache.shared.reports?.count ?? 0
    var showDeleteAlert: Binding<Bool>?
    var deleteSuccess: Binding<Bool>?

    var reports: [Report] {
        (UserCache.shared.reports ?? [])
            .sorted { $0.date > $1.date }
            .prefix(toShow)
            .map { $0 }
    }

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
            ForEach(reports) { report in
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
