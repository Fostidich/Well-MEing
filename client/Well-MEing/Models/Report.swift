import Foundation

class Report: Identifiable {
    public var id: Date { date }

    public let title: String
    public let date: Date
    public let content: String

    init?(
        title: String,
        date: Date,
        content: String
    ) {
        guard
            let title = title.clean?.prefix(50),
            let content = content.clean?.prefix(2000)
        else {
            return nil
        }
        self.title = String(title)
        self.date = date
        self.content = String(content)
    }

    init?(dict: [String: Any]) {
        guard
            let date = dict["date"] as? String,
            let date = Date.fromString(date),
            let title = dict["title"] as? String,
            let title = title.clean,
            let content = dict["content"] as? String,
            let content = content.clean
        else {
            return nil
        }

        self.date = date
        self.title = String(title.prefix(50))
        self.content = String(content.prefix(2000))
    }

    /// The report object is serialized as a dictionary.
    /// The date field is not included, as the DB object does not contain in, as the date is its key instead.
    /// The ID field is also not included, as it is a redundancy for the date.
    /// Firebase will require the returned dictionary to be casted as a ``NSDictionary``, in order to be uploaded.
    var asDBDict: NSDictionary {
        let dict: [String: Any] = [
            "title": title,
            "content": content,
        ]
        return dict as NSDictionary
    }

}
