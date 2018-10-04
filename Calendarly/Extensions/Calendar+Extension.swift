import Foundation

extension Calendar {

    func weekdayOfFirstDayIn(month: Int, year: Int, config: FirstDayOfWeek) -> Int {
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = config == .monday ? 1 : 0
        return component(.weekday, from: date(from: dateComponents)!)
    }

    public func nbrDaysIn(month: Int, year: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        return range(of: .day, in: .month, for: date(from: dateComponents)!)!.count
    }

    func weekdayPrefixes(month: Int, year: Int, locale: Locale, config: FirstDayOfWeek) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEEE"

        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        dateComponents.year = year
        dateComponents.weekdayOrdinal = config == .monday ? 1 : 0

        return (0...6).map { i in
            dateComponents.weekday = i + (config == .monday ? 2 : 1)
            let date = self.date(from: dateComponents)
            return String(formatter.string(from: date!).uppercased())
        }
    }

    func dateMatrixFor(month: Int, year: Int, config: FirstDayOfWeek) -> [[Int?]] {
        var result: [[Int?]] = []

        // Weekday of 1'st of month
        let weekday = weekdayOfFirstDayIn(month: month, year: year, config: config)
        let nbrDaysInMonth = nbrDaysIn(month: month, year: year)

        var currentDay = config == .monday ? 1 : 0
        var currentIndex = weekday - 2
        var row = [Int?]()

        if currentIndex == -1 {
            currentIndex = 0
        }

        (0..<currentIndex).forEach { _ in row.append(nil) }

        while currentDay <= nbrDaysInMonth {
            row.append(currentDay)

            if (currentIndex + 1) % 7 == 0 {
                result.append(row)
                row = [Int?]()
            }

            currentIndex += 1
            currentDay += 1
        }

        let emptyTrailing = 7 - row.count

        (0..<emptyTrailing).forEach { _ in row.append(nil) }

        result.append(row)
        return result
    }

}
