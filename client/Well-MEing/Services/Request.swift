import FirebaseAuth
import FirebaseDatabase
import Foundation

/// This enum class manages both data upload and download from the Firebase backend's DB and dedicated functions.
enum Request {

    /// After the user selects a list of habits which submissions he want to include for the report generation, this method
    /// (not the caller) calls the ``HistoryManager/retrieveLastMonthSubmissions(habits:)`` method from the ``HistoryManager`` struct.
    /// The submissions, along with the name and bio of the user, are sent to the backend's LLM which hopefully is able to generate a
    /// user-specific report, which is returned after being received.
    /// Note that the name and bio are not required to be set beforehand by the user; they can be empty.
    case processSpeech(speech: String)

    /// Once the speech recognition has been finalized (thanks to the ``SpeechRecognizer`` class), the recognized
    /// text can be sent to this method in order to be processed by the LLM in the backend.
    /// The LLM will hopefully produce and return two lists: one for the new habits creations and one for the submissions the user wants to log.
    /// The JSON received from the backend is thus deserialized and used to update  the `actions:` parameter.
    /// These actions (creation and submissions) are not executed, as the user must be prompted for acceptance beforehand.
    /// It will be a concearn of the caller to confirm the returned actions and call their corresponding methods, which are found here
    /// in the ``Request`` enum class.
    case generateReport(habitNames: [String])

    /// Given an habit (e.g. built from user input), it is inserted in the backend's DB.
    /// There must not be an habit with the same name for the user, as the name is used as unique key.
    /// The metrics must contain a valid input type, with all its required configuration values.
    /// - SeeAlso: ``InputType`` shows all available input types and the configurations they require.
    case createHabit(habit: Habit)

    /// By providing the name of an habit,
    /// that habit is deleted from the backend's DB.
    case deleteHabit(habitName: String)

    /// Given a submission for an habit, it is recorded in the backend's DB for that habit's history.
    /// The submission's metrics must coincide with all the metrics defined in the habit "template", and they cannot be empty.
    /// - SeeAlso: ``InputType`` shows all available input types and the configurations they require.
    case createSubmission(habitName: String, submission: Submission)

    /// By providing the name of an habit and the ID of a submission,
    /// that submission is deleted from the backend's DB.
    case deleteSubmission(habitName: String, submissionId: String)

    /// By providing the date of a report,
    /// that report is deleted from the backend's DB.
    case deleteReport(reportDate: Date)

    /// The username of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 4-32
    /// characters long range.
    /// A valid username only contains upper and lower case letters and white spaces.
    /// Numbers and symbols are invalid.
    /// White-space only text is invalid.
    case updateName(name: String?)

    /// The bio of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 8-256
    /// characters long range.
    /// A valid bio only can contain whichever character (lower/upper case letters, numbers, symbols, spaces), but white-space only text is invalid.
    case updateBio(bio: String?)

    var responseHasBody: Bool {
        switch self {
        case .processSpeech: return true
        case .generateReport: return true
        default: return false
        }
    }

    var method: String {
        switch self {
        case .processSpeech: return "POST"
        case .generateReport: return "POST"
        case .createHabit: return "POST"
        case .deleteHabit: return "DELETE"
        case .createSubmission: return "POST"
        case .deleteSubmission: return "DELETE"
        case .deleteReport: return "DELETE"
        case .updateName(let name):
            return name.clean == nil ? "DELETE" : "POST"
        case .updateBio(let bio):
            return bio.clean == nil ? "DELETE" : "POST"
        }
    }

    var endpoint: String {
        switch self {
        case .processSpeech:
            return "https://process-speech-tsdlh7jumq-ew.a.run.app"
        case .generateReport:
            return "https://generate-report-tsdlh7jumq-ew.a.run.app"
        case .createHabit:
            return "https://create-habit-tsdlh7jumq-ew.a.run.app"
        case .deleteHabit:
            return "https://delete-habit-tsdlh7jumq-ew.a.run.app"
        case .createSubmission:
            return "https://create-submission-tsdlh7jumq-ew.a.run.app"
        case .deleteSubmission:
            return "https://delete-submission-tsdlh7jumq-ew.a.run.app"
        case .deleteReport:
            return "https://delete-report-tsdlh7jumq-ew.a.run.app"
        case .updateName:
            return "https://update-name-tsdlh7jumq-ew.a.run.app"
        case .updateBio:
            return "https://update-bio-tsdlh7jumq-ew.a.run.app"
        }
    }

    var path: URL? {
        var parameters: [URLQueryItem] = []

        switch self {
        case .createHabit(let habit):
            parameters.append(
                URLQueryItem(name: "habit", value: habit.name))
        case .deleteHabit(let habitName):
            parameters.append(
                URLQueryItem(name: "habit", value: habitName))
        case .createSubmission(let habitName, _):
            parameters.append(
                URLQueryItem(name: "habit", value: habitName))
        case .deleteSubmission(let habitName, let submissionId):
            parameters.append(
                URLQueryItem(name: "habit", value: habitName))
            parameters.append(
                URLQueryItem(name: "submission", value: submissionId))
        case .deleteReport(let reportDate):
            parameters.append(
                URLQueryItem(name: "report", value: reportDate.toString))
        default: break
        }

        var components = URLComponents(string: self.endpoint)
        components?.queryItems = parameters
        return components?.url
    }

    @MainActor var body: NSDictionary? {
        switch self {
        case .processSpeech(let speech):
            let lastWeekHabits: [String: NSDictionary] =
                HistoryManager
                .habitsWithLastWeekSubmissions()
                .reduce(into: [:]) { result, record in
                    result[record.name] = record.asDBDict
                }
            let body: [String: Any] = [
                "speech": speech,
                "habits": lastWeekHabits,
            ]
            return body as NSDictionary
        case .generateReport(let habitNames):
            let lastMonthHabits: [String: NSDictionary] =
                HistoryManager
                .habitsWithLastMonthSubmissions(habits: habitNames)
                .reduce(into: [:]) { result, record in
                    result[record.name] = record.asDBDict
                }
            var body: [String: Any] = [
                "habits": lastMonthHabits
            ]
            if let name = UserCache.shared.name {
                body["name"] = name
            }
            if let bio = UserCache.shared.bio {
                body["bio"] = bio
            }
            return body as NSDictionary
        case .createHabit(let habit):
            return ["habit": habit.asDBDict]
        case .createSubmission(_, let submission):
            return ["submission": submission.asDBDict]
        case .updateName(let name):
            if let name = name.clean { return ["name": name] }
        case .updateBio(let bio):
            if let bio = bio.clean { return ["bio": bio] }
        default: return nil
        }
        return nil
    }

    static func fetchToken() async -> String? {
        do {
            return try await Auth.auth().currentUser?.getIDTokenResult().token
        } catch {
            print("Failed to get authorization token:", error)
            return nil
        }
    }

    @MainActor func request() async -> URLRequest? {
        // HTTP path
        guard let url = self.path
        else { return nil }
        var request = URLRequest(url: url)

        // HTTP method
        request.httpMethod = self.method

        // HTTP headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = await Self.fetchToken() {
            request.addValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization")
        }

        // HTTP payload
        if let body = self.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    /// Based upon the request case chosen, and thus the Firebase function selected, a
    /// request is built with the right attributes and sent to the backend.
    /// All returned status codes outside the 200-299 range are considered errors.
    @MainActor func call() async -> (Bool, [String: Any]?) {
        print("Calling function with \(self.path?.absoluteString ?? "?")")

        var errors = false
        var object: [String: Any]?
        connect: do {
            // Send request to function and wait for response
            guard let request = await self.request() else { break connect }
            let response = try await URLSession.shared.data(for: request)

            // Get status code
            guard let statusCode = (response.1 as? HTTPURLResponse)?.statusCode
            else { break connect }

            // Judge status code
            guard (200...299).contains(statusCode)
            else {
                print("Function call failed with code \(statusCode)")
                if let message = String(data: response.0, encoding: .utf8) {
                    print("Error message: \(message)")
                }
                errors = true
                break connect
            }

            // Get json data
            if self.responseHasBody {
                let data = try JSONSerialization.jsonObject(with: response.0)
                if let dict = data as? [String: Any] { object = dict }
            }
        } catch {
            // Catch request errors
            print("Error in calling function: \(error.localizedDescription)")
            errors = true
        }

        // Update user local data
        Task(operation: UserCache.shared.fetchUserData)
        return (!errors, object)
    }

    /// The whole user data in the DB is fetched and put into the ``UserCache`` class' shared object.
    /// The object is static, thus its variables can be retrieve from everywhere.
    /// - SeeAlso: ``UserCache`` contains static data of the user.
    static func fetchUserData() {
        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return
        }

        // Get db reference and navigate the required data path
        let reference =
            Database
            .database()
            .reference()
            .child("users")
            .child(userId)

        // Download user data
        reference.observeSingleEvent(of: .value) { snapshot in
            // Map the data into objects
            let data = snapshot.value as? [String: Any]
            Task { @MainActor in UserCache.shared.fromDictionary(data) }
            print("Updating user data")
        }
    }

}
