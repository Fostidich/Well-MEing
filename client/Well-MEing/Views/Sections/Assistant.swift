import Foundation
import SwiftUI

struct Assistant: View {
    @State private var selectedReport: Report?
    @State private var toShow: Int = 1
    private let reportsCount: Int = UserCache.shared.reports?.count ?? 0

    var reports: [Report] {
        (UserCache.shared.reports ?? [])
            .sorted { $0.date > $1.date }
            .prefix(toShow)
            .map { $0 }
    }

    var body: some View {
        // Generate report button
        RequestReportButton()

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
            }

            // Button to show older reports
            if toShow < reportsCount {
                Button(action: {
                    toShow += 10
                }) {
                    Text("Load more")
                        .padding()
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
