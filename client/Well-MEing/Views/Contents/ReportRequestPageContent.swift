import SwiftUI

struct ReportRequestPageContent: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Show fields to edit user data
                UpdateUserDataBlock()

                // Show habit selector for report request
                ReportRequestBuilderBlock()

                Spacer()
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

}

#Preview {
    ReportRequestPageContent()
}
