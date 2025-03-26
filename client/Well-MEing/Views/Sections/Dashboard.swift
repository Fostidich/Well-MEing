import SwiftUI

struct Dashboard: View {
    var body: some View {
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
