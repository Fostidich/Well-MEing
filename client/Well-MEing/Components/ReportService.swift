/// At a set cadence, the submissions history of the last period must be received
/// and sent to the AI assistant, for it to generate a user-specific report. This component makes
/// the call to the LLM for receving the report text, allowing the View to also retrieve and show
/// past reports. It also manages the user personal information DB insertions.
struct ReportService {
    
    /// Since the report may be asked once a week at maximum, this method return the cooldown time
    /// that the user is required to wait before requesting a new report.
    /// If the returned value is `nil`, than the timer is elapsed therefore allowing the user to make a new request.
    static func showTimer() -> String? {
        // TODO: define method
        return nil
    }
    
    /// After the user selects a list of habits which submissions he want to include for the report generation, this method
    /// (not the caller) calls the ``HistoryManager/retrieveLastWeekSubmissions(habits:)`` method from the ``HistoryManager`` struct.
    /// The submissions, along with the name and bio of the user, are sent to the backend's LLM which hopefully is able to generate a
    /// user-specific report, which is returned after being received.
    /// Note that the name and bio are not required to be set beforehands by the user; they can be empty.
    static func getNewReport(habits: [String]) -> String? {
        // TODO: define method
        return nil
    }
    
    /// The last 10 reports the user requested are returned.
    static func getPastReports() -> [String] {
        // TODO: define method
        return []
    }
    
    /// The username of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 4-32
    /// characters long range.
    /// A valid username only contains upper and lower case letters and white spaces.
    /// Numbers and symbols are invalid.
    /// White-space only text is invalid.
    static func updateUsername(username: String) -> Bool {
        // TODO: define method
        return true;
    }
     
    /// The bio of the user is updated in the DB.
    /// It can be (re)set to empty (which is also the fallback option for invalid insertions), but if the provided text is valid, it must be in the 8-256
    /// characters long range.
    /// A valid bio only can contain whichever character (lower/upper case letters, numbers, symbols, spaces), but white-space only text is invalid.
    static func updateBio(bio: String) -> Bool {
        // TODO: define method
        return true;
    }
    
}
