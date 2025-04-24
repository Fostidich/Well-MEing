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
        
        // Check that input exists
        if speech.isEmpty { return (nil, nil) }
        
        let actionName = speech
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        let optionalMetrics: [Metric?] = [
            Metric(
                name: "Metric 1",
                description: "Metric 1 description",
                input: .slider,
                config: [
                    "min": 34,
                    "max": 252,
                    "type": "float",
                ]
            ),
            Metric(
                name: "Metric 2",
                input: .text
            ),
            Metric(
                name: "Metric 3",
                input: .form,
                config: [
                    "boxes": [
                        "param1",
                        "param1",
                        "param2",
                    ]
                ]
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
                name: actionName,
                description: "Habit description",
                metrics: metrics
            )
        ]
        let habits: [Habit]? =
            optionalHabits.compactMap { $0 }.isEmpty
            ? nil : optionalHabits.compactMap { $0 }

        let submissions = [
            Submission(
                timestamp: date,
                notes: "Submission notes",
                metrics: [
                    "Metric 1": 00,
                    "Metric 2": "Text metric",
                    "Metric 3": "param1;param2",
                    "Metric 4": "10:30:00",
                    "Metric 5": 2,
                ]
            )
        ]

        Thread.sleep(forTimeInterval: 1)
        return (habits, [actionName: submissions[0]])
        
    }

}
