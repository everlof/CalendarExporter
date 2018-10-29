// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

struct BirthdayEvent: Codable {

    enum YearsTurned {
        case unknown
        case years(Int)
    }

    let year: Int?

    let month: Int

    let day: Int

    func daysUntilBirthday(today _today: Date = Date()) -> Int {
        var calendar: Calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let todayComponents = calendar.dateComponents([.year, .month, .day], from: _today)
        let today = calendar.date(from: DateComponents(calendar: calendar,
                                                        year: todayComponents.year,
                                                        month: todayComponents.month,
                                                        day: todayComponents.day))!

        guard
            let birthdayThisYear =
            calendar.date(from: DateComponents(calendar: calendar,
                                               year: todayComponents.year,
                                               month: month,
                                               day: day)),
            let birthdayNextYear =
            calendar.date(from: DateComponents(calendar: calendar,
                                               year: todayComponents.year! + 1,
                                               month: month,
                                               day: day))
            else { fatalError() }

        guard
            let currentMonth = todayComponents.month,
            let currentDay = todayComponents.day else { fatalError() }

        if month == currentMonth && day == currentDay {
            return 0
        } else if birthdayThisYear < Date() {
            return calendar.dateComponents([.day], from: today, to: birthdayNextYear).day!
        } else {
            return calendar.dateComponents([.day], from: today, to: birthdayThisYear).day!
        }
    }

    func nbrYearsTurned(today: Date = Date()) -> YearsTurned {
        let calendar: Calendar = Calendar.current

        guard let year = year else { return .unknown }
        guard year > 0 else { return .unknown }

        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)

        guard let birthdayThisYear =
            calendar.date(from: DateComponents(calendar: calendar,
                                               year: todayComponents.year,
                                               month: month,
                                               day: day))
            else { return .unknown }

        guard
            let currentYear = todayComponents.year,
            let currentMonth = todayComponents.month,
            let currentDay = todayComponents.day else { return .unknown }

        if month == currentMonth && day == currentDay {
            // Birthday is today
            return .years(currentYear - year)
        } else if birthdayThisYear < Date() {
            return .years(currentYear - year + 1)
        } else {
            return .years(currentYear - year)
        }
    }

}

extension BirthdayEvent.YearsTurned: Equatable {

    static func == (lhs: BirthdayEvent.YearsTurned, rhs: BirthdayEvent.YearsTurned) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.years(let lhsYears), .years(let rhsYears)):
            return lhsYears == rhsYears
        default:
            return false
        }
    }

}

extension BirthdayEvent: CustomStringConvertible {

    var description: String {
        switch nbrYearsTurned() {
        case .years(let years):
            let days = daysUntilBirthday()
            switch days {
            case 0:
                return "Turns \(years) today!"
            case 1:
                return "Turns \(years) tomorrow."
            default:
                return "Turns \(years) in \(days) days."
            }
        case .unknown:
            let days = daysUntilBirthday()
            switch days {
            case 0:
                return "Birthday today!"
            case 1:
                return "Birthday tomorrow."
            default:
                return "Birthday in \(days) days."
            }
        }
    }

}
