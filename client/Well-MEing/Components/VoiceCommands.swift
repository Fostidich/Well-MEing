import FirebaseFunctions
import Foundation
import SwiftUI

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
    /// The JSON received from the backend is thus deserialized and used to update  the `actions:` parameter.
    /// These actions (creation and submissions) are not executed, as the user must be prompted for acceptance beforehand.
    /// It will be a concearn of the caller to confirm the returned actions and call their corresponding methods, which are found in
    /// the ``HabitManager``.
    @MainActor static func processSpeech(speech: String, actions: Binding<Actions?>)
        -> Bool
    {
        // Check that input exists
        if speech.isWhite {
            actions.wrappedValue = nil
            return false
        }

        // Call function while checking for errors
        var errors = false
        Functions.functions().httpsCallable("process_speech").call([
            "speech": speech
        ]) { result, error in
            if let error = error {
                print(
                    "Error while calling function: \(error.localizedDescription)")
                errors = true
            } else if let data = result?.data as? [String: Any] {
                // Parse successfully received data
                print("Data received from function call")
                actions.wrappedValue = Actions(dict: data)
            } else {
                print("Error while receiving function data")
                errors = true
            }
        }

        // Update user local data
        UserCache.shared.fetchUserData()
        return !errors
    }

}
