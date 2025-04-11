import SwiftUI

struct HabitModalContent: View {
    let habit: Habit

    var body: some View {
        // Show big habit name
        Text(habit.name)
            .bold()
            .font(.title)

        // Show habit description
        if let description = habit.description {
            Text("Description")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.top)
            Text(description)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
        }

        // Show habit goal
        if let goal = habit.goal {
            Text("Goal")
                .bold()
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.top)
            Text(goal)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
        }

        Text("Insert metrics")
            .font(.title2)
            .bold()
            .padding(.vertical)

        ForEach(habit.metrics) { metric in
            Text(metric.name)
                .font(.title3)

            // Show metric description
            if let description = metric.description {
                Text(description)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
            }

            Text(metric.inputType.rawValue)
                .font(.callout)
                .foregroundColor(.primary)
                .padding(.bottom)
        }
    }
}
