import SwiftUI

struct HealthSyncPageContent: View {
    @State private var actions: Actions? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Actions buttons
                ImportRangeFromHealth(actions: $actions)

                // Show habits found
                RecognizedHabitCreationList(actions: $actions)

                // Show submissions found
                RecognizedHabitLoggingList(actions: $actions)

                Spacer()
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

}

#Preview {
    HealthSyncPageContent()
}
