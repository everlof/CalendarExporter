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


import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "CalendarCollectionViewCell"

    private let dateLabel = UILabel()

    private let birthdayLabel = UILabel()

    var calendarView: CalendarView?

    var date: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(dateLabel)
        addSubview(birthdayLabel)

        dateLabel.textAlignment = .center
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        birthdayLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        birthdayLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func set(date: String?, fullDate: Date?, design: Design, indexPath: IndexPath, calendarView: CalendarView) {
        self.calendarView = calendarView
        self.date = fullDate

        if indexPath.row < 7 {
            dateLabel.font = calendarView.aggregatedHeaderFont
            dateLabel.textColor = indexPath.row % 7 == 0 ? design.secondaryColor(for: Int(design.previewMonth)) : design.primaryColor(for: Int(design.previewMonth))
            dateLabel.text = calendarView.weekdayPrefixes[indexPath.row]
        } else {
            dateLabel.font = calendarView.aggregatedDateFont
            dateLabel.textColor = indexPath.row % 7 == 0 ? design.secondaryColor(for: Int(design.previewMonth)) : design.primaryColor(for: Int(design.previewMonth))
            dateLabel.attributedText = NSAttributedString(string: date ?? "", attributes: [
                NSAttributedString.Key.kern: calendarView.unit * CGFloat(design.dateKerning)
            ])
        }
    }

    func event(_ events: [CalendarEvent]) {
        birthdayLabel.isHidden = events.count == 0
        birthdayLabel.font = calendarView?.aggregatedFont(size: 1.0, style: .date)

        if let event = events.first {
            if let date = date, case .years(let year) = event.yearsSince(today: date) {
                birthdayLabel.text = "\(event.text), \(year)"
            } else {
                birthdayLabel.text = event.text
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
