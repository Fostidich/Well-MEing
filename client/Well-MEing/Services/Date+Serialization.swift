import Foundation

extension Date {

    var fancyString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy HH:mm"
        return formatter.string(from: self)
    }

    var fancyDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: self)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: self)
    }

    static func fromString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: string) ?? nil
    }

    static func weekRangeString(_ offset: Int) -> String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = Date()

        guard
            let baseWeekStart = calendar.dateInterval(
                of: .weekOfYear, for: today)?.start,
            let weekStart = calendar.date(
                byAdding: .day, value: 7 * offset, to: baseWeekStart),
            let weekEnd = calendar.date(
                byAdding: .day, value: 6, to: weekStart)
        else { return "? - ?" }

        return "\(weekStart.fancyDateString) - \(weekEnd.fancyDateString)"
    }

    static func weekDayString(_ index: Int) -> String {
        return DateFormatter().shortWeekdaySymbols[(index + 1) % 7]
    }

    func inWeek(_ offset: Int) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard
            let targetWeek = calendar.date(
                byAdding: .weekOfYear, value: offset, to: Date())
        else { return false }
        return calendar.isDate(
            self, equalTo: targetWeek, toGranularity: .weekOfYear)
    }

    var weekdayIndex: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        return (weekday + 5) % 7
    }

}
