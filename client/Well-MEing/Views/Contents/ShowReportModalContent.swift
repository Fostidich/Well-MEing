import SwiftUI

struct ShowReportModalContent: View {
    let report: Report

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(report.title)
                    .bold()
                    .font(.title)
                    .foregroundColor(.accentColor)
                Text(report.date.fancyDateString)
                    .foregroundColor(.secondary)
                Text(
                    (try? AttributedString(markdown: report.content))
                        ?? "Invalid text"
                )
                .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

}
