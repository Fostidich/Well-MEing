import FirebaseDatabase
import Foundation

/// The habit manager collects all the functions that are used for creating, editing
/// and deleting the habits that the user is tracking, each with its internal metrics. Furthermore,
/// it contains the call needed for logging an habit submission.
struct HabitManager {
  
    /// Given an habit (e.g. built from user input), it is inserted in the backend's DB.
    /// There must not be an habit with the same name for the user, as the name is used as unique key.
    /// The metrics must contain a valid input type, with all its required configuration values.
    /// - SeeAlso: ``InputType`` shows all available input types and the configurations they require.
    static func createHabit(habit: Habit) -> Bool {
        // TODO: define method
        return true
    }

    /// By providing the name of an habit and the timestamp of a submission (which acts like a unique key),
    /// that submission is deleted from the backend's DB.
    static func deleteHabit(habitName: String, timestamp: Date) -> Bool {
        // TODO: define method
        return true
    }

    /// Given a submission for an habit, it is recorded in the backend's DB for that habit's history.
    /// There must not be a submission for that habit with the same timestamp, as the timestamp is used as unique key.
    /// The submission's metrics must coincide with all the metrics defined in the habit "template", and they cannot be empty.
    /// - SeeAlso: ``InputType`` shows all available input types and the configurations they require.
    static func recordSubmission(submission: Submission) -> Bool {
        // TODO: define method
        return true
    }
    
}
