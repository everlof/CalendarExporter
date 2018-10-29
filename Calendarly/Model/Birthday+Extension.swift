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

extension Birthday {

    enum Source {
        case contacts
        case facebook
        case created
    }

    var source: Source {
        if contact != nil {
            return .contacts
        }

        return .created
    }

    var day: Int {
        if let contact = contact {
            return Int(contact.day)
        }

        return Int(day_)
    }

    var month: Int {
        if let contact = contact {
            return Int(contact.month)
        }

        return Int(month_)
    }

    var year: Int {
        if let contact = contact {
            return Int(contact.year)
        }

        return Int(year_)
    }

    var name: String {
        if let name = name_ {
            return name
        }

        if let name = contact?.name {
            return name
        }

        fatalError()
    }

    var birthdayEvent: BirthdayEvent {
        return BirthdayEvent(year: year, month: month, day: day)
    }

}
