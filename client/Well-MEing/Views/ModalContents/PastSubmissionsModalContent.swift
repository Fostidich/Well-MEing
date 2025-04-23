import SwiftUI

struct PastSubmissionsModalContent: View {
    @State private var showDeleteAlert: Bool = false
    @State private var deleteSuccess: Bool = false
    let date: Date

    var body: some View {
        VStack {
            ForEach(submissions, id: \.1.id) { habit, submission in
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

    private var submissions: [(Habit, Submission)] {
        return (UserCache.shared.habits ?? [])
            .flatMap { habit in
                habit.getSubmissions(day: date).map { submission in
                    (habit, submission)
                }
            }
            .sorted { $0.1.timestamp > $1.1.timestamp }
    }

}

#Preview {
    let date = Date()

    let optionalMetrics: [Metric?] = [
        Metric(
            name: "Metric 1",
            input: .slider
        ),
        Metric(
            name: "Metric 2",
            input: .text
        ),
        Metric(
            name: "Metric 3",
            input: .form
        ),
        Metric(
            name: "Metric 4",
            input: .time
        ),
        Metric(
            name: "Metric 5",
            input: .rating
        ),
    ]
    let metrics: [Metric]? =
        optionalMetrics.compactMap { $0 }.isEmpty
        ? nil : optionalMetrics.compactMap { $0 }

    let optionalHabits = [
        Habit(
            name: "Habit 1",
            description:
                "Io non so veramente nulla di questo corso, se ci trovassimo su ds uno di questi giorni per leggere la traccia dell’homework e capire come organizzarci?",
            metrics: metrics,
            history: [
                Submission(
                    timestamp: date,
                    notes:
                        "Congratulate Mattia on starting school at USP - Test Test Universidade de São Paulo",
                    metrics: [
                        "Metric 1": 30,
                        "Metric 2":
                            "Se vuoi passare da Lambrox durante la pausa pranzo mi becchi",
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
