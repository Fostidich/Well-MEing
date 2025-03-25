import SwiftUI

struct Dashboard: View {
    var body: some View {
        // Button list for each task group
        ForEach(MockData.habitGroups, id: \.name) { item in
            DashboardGroup(title: item.name, tasks: item.tasks)
                .padding()
        }
    }
}

struct DashboardGroup: View {
    let title: String
    let tasks: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Task group title
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.primary)
                .padding(.bottom, 5)

            // List all tasks in the group
            ForEach(tasks, id: \.0) { content in
                DashboardItem(content: content)
            }
        }
    }
}

struct DashboardItem: View {
    let content: (String, String)

    var body: some View {
        Button(action: { print("\(content) tapped") }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.20))
         
                // Content of the task button
                DashboardItemContent(content: content)
                    .padding()
            }
        }
    }
}

struct DashboardItemContent: View {
    let content: (String, String)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(content.0)
                .font(.title2)
                .bold()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Task description
            Text(content.1)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
