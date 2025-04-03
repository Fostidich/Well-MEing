import SwiftUI

struct Dashboard: View {
    @State private var showAddHabitModal = false
    var body: some View {
        // Floating "+" Button
        Button(action: {
            showAddHabitModal.toggle()
        }) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4)
                .padding()
        }
        .sheet(isPresented: $showAddHabitModal) {
            AddHabitModal()
        }
        
        // Button list for each task group
        ForEach(MockData.habitGroups, id: \.name) { item in
            DashboardGroup(
                title: item.name, color: item.color, tasks: item.tasks
            )
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

struct DashboardGroup: View {
    let title: String
    let color: Color
    let tasks: [(title: String, description: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Task group title
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // List all tasks in the group
            ForEach(tasks, id: \.title) { content in
                DashboardItem(content: content, color: color)
            }
        }
    }
}

struct DashboardItem: View {
    let content: (String, String)
    let color: Color
    @State private var showModal = false

    var body: some View {
        Button(action: {
            showModal.toggle()
        }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))

                // Content of the task button
                DashboardButtonContent(content: content, color: color)
                    .padding()
            }
        }
        .sheet(isPresented: $showModal) {
            TaskModal(content: content, color: color)
        }
    }
}

struct DashboardButtonContent: View {
    let content: (title: String, description: String)
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(content.title)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct DashboardButtonAddHabit: View {
    let title = "+"
    let content: (title: String, description: String)
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(content.title)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct TaskModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var value: Double = 10
    @State private var submitted: Double? = nil
    let content: (title: String, description: String)
    let color: Color

    var body: some View {
        NavigationStack {
            VStack {
                // Modal content
                Text(content.description)
                    .font(.title3)
                    .padding()
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .foregroundColor(color)

                if let submitted = submitted {
                    Text("Submitted: \(Int(submitted))")
                        .padding()
                }
                Slider(value: $value, in: 0...20)
                    .padding()

                Button(action: {
                    submitted = value
                }) {
                    Text("Log \(Int(value))")
                        .bold()
                        .font(.title3)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.secondary.opacity(0.20))
                        )
                }
                .padding(.bottom)
            }
            .navigationBarTitle(
                content.title,
                displayMode: .inline
            )  // title in center
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()  // dismiss modal
                })
        }
    }
}

struct AddHabitModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var habitName: String = ""
    @State private var habitDescription: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Habit Name Input
                TextField("Habit name...", text: $habitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Habit Description Input
                TextField("Habit description...", text: $habitDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Save Button
                Button(action: {
                    saveHabit()
                    dismiss()
                }) {
                    Text("Save Habit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("New Habit")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }

    // Function to handle saving the habit
    private func saveHabit() {
        guard !habitName.isEmpty else { return }
        print("New Habit: \(habitName) - \(habitDescription)")
        // Here, you could add logic to store the new habit in your data model
    }
}
