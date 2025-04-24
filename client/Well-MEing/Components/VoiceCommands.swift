import Foundation

/// Here are organized all the functionalities that allow the user to send its speech to the AI assistant to be processed,
/// for then receving the actions the LLM has interpreted (habit creations and submissions), that by the way the user has to confirm.
/// This struct operates with speech which has already been recognized and translated to text.
/// It does not include code for recognizing speech, as this is managed by the ``SpeechRecognizer`` class.
/// It does not also include code for executing the recognized actions (habit creations and submission),
/// as this is a concearn of the ``HabitManager`` struct.
struct VoiceCommands {

    /// Once the speech recognition has been finalized (thanks to the ``SpeechRecognizer`` class), the recognized
    /// text can be sent to this method in order to be processed by the LLM in the backend.
    /// The LLM will hopefully produce and return two lists: one for the new habits creations and one for the submissions the user wants to log.
    /// The JSON received from the backend is thus deserialized and returned.
    /// These actions (creation and submissions) are not executed, as the user must be prompted for acceptance beforehand.
    /// It will be a concearn of the caller to confirm the returned actions and call their corresponding methods, which are found in
    /// the ``HabitManager``.
    static func processSpeech(speech: String) -> (
        habits: [Habit]?,
        submissions: [String: Submission]?
    ) {
        // TODO: define method
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
                metrics: metrics
            )
        ]
        let habits: [Habit]? =
            optionalHabits.compactMap { $0 }.isEmpty
            ? nil : optionalHabits.compactMap { $0 }

        let submissions = [
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

        Thread.sleep(forTimeInterval: 1)
        return (habits, ["New habit 1": submissions[0]])
    }

}
