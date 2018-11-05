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

struct BirthdayCellFormatter: CalendarEventFormatter {

    func stringFor(years: Int, andDays days: Int, forEvent event: CalendarEvent) -> String {
        switch days {
        case 0:
            return "\(event.text) turns \(years) today!"
        case 1:
            return "\(event.text) turns \(years) tomorrow."
        default:
            return "\(event.text) turns \(years) in \(days) days."
        }
    }

    func stringFor(days: Int, forEvent event: CalendarEvent) -> String {
        let ending = (event.text.last == .some("s") || event.text.last == .some("S")) ? "'" : "'s"
        switch days {
        case 0:
            return "\(event.text)\(ending) birthday is today!"
        case 1:
            return "\(event.text)\(ending) birthday is tomorrow."
        default:
            return "\(event.text)\(ending) birthday is in \(days) days."
        }
    }

}
