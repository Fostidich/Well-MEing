import FirebaseFunctions
import Foundation
import SwiftUI

private let processSpeechFirebaseFunctionEndpoint: String =
    "https://process-speech-tsdlh7jumq-ew.a.run.app"

/// Here are organized all the functionalities that allow the user to send its speech to the AI assistant to be processed,
/// for then receiving the actions the LLM has interpreted (habit creations and submissions), that by the way the user has to confirm.
/// This struct operates with speech which has already been recognized and translated to text.
/// It does not include code for recognizing speech, as this is managed by the ``SpeechRecognizer`` class.
/// It does not also include code for executing the recognized actions (habit creations and submission),
/// as this is a concearn of the ``HabitManager`` struct.
struct VoiceCommands {

    /// Once the speech recognition has been finalized (thanks to the ``SpeechRecognizer`` class), the recognized
    /// text can be sent to this method in order to be processed by the LLM in the backend.
    /// The LLM will hopefully produce and return two lists: one for the new habits creations and one for the submissions the user wants to log.
    /// The JSON received from the backend is thus deserialized and used to update  the `actions:` parameter.
    /// These actions (creation and submissions) are not executed, as the user must be prompted for acceptance beforehand.
    /// It will be a concearn of the caller to confirm the returned actions and call their corresponding methods, which are found in
    /// the ``HabitManager``.
    @MainActor static func processSpeech(
        speech: String, actions: Binding<Actions?>
    )
        async -> Bool
    {
        print("Processing speech")

        // Reset recipient object
        actions.wrappedValue = nil

        // Check that input exists
        if speech.isWhite { return false }

        // Get required data to send
        var lastWeekHabits: [String: NSDictionary] = [:]
        HistoryManager
            .habitsWithLastWeekSubmissions()
            .forEach {
                lastWeekHabits[$0.name] = $0.asDBDict
            }

        // Check that URL endpoint is valid
        guard let url = URL(string: processSpeechFirebaseFunctionEndpoint)
        else { return false }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["speech": speech, "habits": lastWeekHabits]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        var errors = false
        do {
            // Send request to function
            let (data, _) = try await URLSession.shared.data(for: request)

            // Deserialize response
            if let json = try JSONSerialization.jsonObject(with: data)
                as? [String: Any]
            {
                actions.wrappedValue = Actions(dict: json)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            errors = true
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        return !errors
    }

}
