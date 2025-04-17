import Foundation
import SwiftUI

struct Assistant: View {
    @State private var showModal = false

    var body: some View {
        HButton(text: "Request report", textColor: .accentColor) {
            print("report please")
        }
        .padding()
        .bold()
        .font(.title3)
        
        // Show reports title
        Text("Reports")
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)

        // List all past reports
        ForEach(MockData.pastReports, id: \.title) { item in
            ReportCard(
                title: item.title, date: item.date,
                color: item.color, text: item.text
            )
            .padding(.horizontal)
        }
    }
}

struct ReportCard: View {
    let title: String
    let date: Date
    let color: Color
    let text: String
    @State private var showModal: Bool = false

    var body: some View {
        Button(action: {
            showModal.toggle()
        }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))

                // Content of the report button
                ReportCardContent(
                    title: title, date: date,
                    color: color
                )
                .padding(.bottom)
            }
        }
        .padding(.vertical, 10)
        .sheet(isPresented: $showModal) {
            ReportModal(
                title: title, date: date,
                color: color, text: text
            )
        }
    }
}

struct ReportCardContent: View {
    let title: String
    let date: Date
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Colored part of the button
            Rectangle()
                .fill(color.opacity(0.80))
                .frame(height: 80)

            // Report date
            Text(date.shortString)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Report title
            Text(title)
                .bold()
                .foregroundColor(.primary)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
        }
        .cornerRadius(10)
    }
}

struct ReportModal: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let date: Date
    let color: Color
    let text: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                // Modal content
                Text(title)
                    .font(.title)
                    .padding(.bottom)
                Text(text)
            }
            .navigationBarTitle(
                "Report of " + date.shortString,
                displayMode: .inline
            )  // title in center
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()  // dismiss modal
                }
            )
            .frame(
                maxWidth: .infinity, maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
        }
    }
}
