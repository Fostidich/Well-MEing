import SwiftUI
import MarkdownUI

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
                Markdown(report.content)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

}

