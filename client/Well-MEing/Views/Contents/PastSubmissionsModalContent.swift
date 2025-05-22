import SwiftUI

struct PastSubmissionsModalContent: View {
    @State private var showDeleteAlert: Bool = false
    @State private var deleteSuccess: Bool = false
    let date: Date

    var body: some View {
        // Show all submissions of the day
        VStack {
            ForEach(allDateSubmissions, id: \.1.id) { habit, submission in
                SubmissionView(
                    showDeleteAlert: $showDeleteAlert,
                    deleteSuccess: $deleteSuccess,
                    habitName: habit.name,
                    metricTypes: habit.metricTypes,
                    submission: submission
                )
            }
        }
        .alert(
            deleteSuccess
                ? "Submission deleted successfully"
                : "Failed to delete submission",
            isPresented: $showDeleteAlert
        ) {
            Button("OK", role: .cancel) {}
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: showDeleteAlert)
    }

    var allDateSubmissions: [(Habit, Submission)] {
        (UserCache.shared.habits ?? [])
            .flatMap { habit in
                habit.getSubmissions(day: date).map { submission in
                    (habit, submission)
                }
            }
            .sorted { $0.1.timestamp < $1.1.timestamp }
    }

}

#Preview {
    let date = Date()

    let optionalMetrics: [Metric?] = [
        Metric(name: "Metric 1", input: .slider),
        Metric(name: "Metric 2", input: .text),
        Metric(name: "Metric 3", input: .form),
        Metric(name: "Metric 4", input: .time),
        Metric(name: "Metric 5", input: .rating),
    ]
    let metrics: [Metric]? =
        optionalMetrics.compactMap { $0 }.isEmpty
        ? nil : optionalMetrics.compactMap { $0 }

    let optionalHabits = [
        Habit(
            name: "Habit 1",
            description: "A normal description",
            metrics: metrics,
            history: [
                Submission(
                    timestamp: date,
                    notes: "Notes are optional by the way",
                    metrics: [
                        "Metric 1": 30,
                        "Metric 2": "Text metric",
                        "Metric 3": "Paolo;Marco;Giovanni",
                        "Metric 4": "10:30",
                        "Metric 5": 2,
                    ]
                )
            ]
        )
    ]
    let habits: [Habit]? =
        optionalHabits.compactMap { $0 }.isEmpty
        ? nil : optionalHabits.compactMap { $0 }

    UserCache.shared.habits = habits
    return Modal(title: date.fancyDateString, dismissButton: .cancel) {
        PastSubmissionsModalContent(date: date)
    }
}
