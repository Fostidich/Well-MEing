import SwiftUI

struct HabitCreationModalContent: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var goal: String = ""

    var body: some View {
        CreationIntroView(name: $name, description: $description, goal: $goal)

        // TODO: when pressing create button, check that names of habit and metrics are not empty
    }
}

struct CreationIntroView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var goal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Habit name", text: $name)
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
            Divider()
                .padding(.bottom)

            Text("Description")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)

            TextField("Give a description", text: $description)
            Divider()
                .padding(.bottom)

            Text("Goal")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)

            TextField("Set a goal", text: $goal)
            Divider()
                .padding(.bottom)
        }
    }
}

#Preview {
    Modal(title: "Create an habit", dismissButton: .cancelAndDone) {
        HabitCreationModalContent()
    }
}
