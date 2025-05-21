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
                reportContentText
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var reportContentText: Text {
        if let content = try? AttributedString(
            markdown: report.content,
            options:
                AttributedString
                .MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace))
        {
            return Text(content)
        } else {
            return Text("Invalid text")
        }

    }

}
