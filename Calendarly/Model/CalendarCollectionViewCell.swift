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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func set(date: String?, design: Design, indexPath: IndexPath, calendarView: CalendarView) {
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
