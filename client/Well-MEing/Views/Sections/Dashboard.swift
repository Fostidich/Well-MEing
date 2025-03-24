import SwiftUI

struct Dashboard: View {
    @Binding var scrollOffset: CGFloat

    var body: some View {
        // Page title
        Text("Dashboard")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle)
            .bold()
            .foregroundColor(.white)
            .opacity(CGFloat(max(0, 1 - scrollOffset / 24))) // set vanishing rapidity
            .padding()

        // Button list for each task group
        VStack(alignment: .leading, spacing: 20) {
            ForEach(MockData.habitGroups, id: \.name) { item in
                DashboardGroup(title: item.name, tasks: item.tasks)
            }
        }
        .padding()
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
                .foregroundColor(.white)
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
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.20))
                .frame(height: 100)
                .padding(5)
                .overlay(DashboardItemContent(content: content))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct DashboardItemContent: View {
    let content: (String, String)
    
    var body: some View {
        VStack {
            // Task title
            Text(content.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .foregroundColor(.teal)
            
            Spacer().frame(height: 16)
            
            // Task description
            Text(content.1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
                .padding(.horizontal)
        }
    }
}
