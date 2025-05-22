import SwiftUI

struct VoiceCommandsPageContent: View {
    @State private var actions: Actions? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Actions buttons
                VoiceCommandsRecorderBlock(actions: $actions)

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
    VoiceCommandsPageContent()
}
