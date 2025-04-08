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
    /// These actions (creation and submissions) are not executed, as the user must be prompted for acceptance beforehands.
    /// It will be a concearn of the caller to confirm the returned actions and call their corresponding methods, which are found in
    /// the ``HabitManager``.
    static func processSpeech(speech: String) -> (
        habits: [Habit],
        submissions: [Submission]
    ) {
        // TODO: define method
        return ([], [])
    }

}
