import Foundation
import SwiftUI

struct Assistant: View {
    @State private var showDeleteAlert = false
    @State private var deleteSuccess = false

    var body: some View {
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
            .sensoryFeedback(.impact(weight: .heavy), trigger: showDeleteAlert)
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
        }
        .padding()
        .buttonStyle(.plain)
    }
}

