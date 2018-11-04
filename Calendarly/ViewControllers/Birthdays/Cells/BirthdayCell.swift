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
import CoreData
import Contacts

class BirthdayCell: FRCCell<Birthday> {

    var birthday: Birthday?

    let nameLabel = UILabel()

    let descriptionlabel = UILabel()
    
    var style: BirthdaysViewController.Style = .standalone

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .boneContrastLighter

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionlabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionlabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9).isActive = true

        descriptionlabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        descriptionlabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true

        descriptionlabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(for birthday: Birthday) {
        switch style {
        case .inDesign(let design):
            selectionStyle = .gray
            accessoryType = birthday.designs?.contains(design) == .some(true) ? .checkmark : .none
        case .standalone:
            selectionStyle = .none
        }

        descriptionlabel.text = birthday.calendarEvent.description
        self.birthday = birthday
        nameLabel.text = birthday.name_
    }

}
