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
import Contacts
import CoreData

extension Notification.Name {
    static let moveImageNotification = Notification.Name(rawValue: "moveImageNotification")
}

class ContactButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + 24, height: s.height + 6)
    }

}

class ContactCell: FRCCell<Contact> {

    let profileImageView = ProfileImageView()

    let nameLabel = UILabel()

    let descriptionlabel = UILabel()

    let button = ContactButton(type: .custom)

    lazy var store = CNContactStore()

    var contact: Contact?

    var persistentContainer: NSPersistentContainer?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = UIColor.boneContrastLighter

        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionlabel)
        contentView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didPress), for: .touchUpInside)
        button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -18).isActive = true
        button.backgroundColor = UIColor.boneConstrastDarker
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)

        button.setTitleColor(UIColor.complementary, for: .normal)
        button.setTitleColor(UIColor.complementary.withAlphaComponent(0.5), for: .disabled)

        button.setTitle("Add", for: .normal)
        button.setTitle("Added", for: .disabled)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionlabel.translatesAutoresizingMaskIntoConstraints = false

        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true

        profileImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 9).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didPress() {
        guard let objectID = self.contact?.objectID else { return }
        profileImageView.takeOff(with: FlyingView.active) {
            self.persistentContainer?.performBackgroundTask { ctx in
                let contact = ctx.object(with: objectID) as! Contact
                let birthday = NSEntityDescription.insertNewObject(forEntityName: Birthday.self.description(), into: ctx) as! Birthday
                contact.birthday = birthday
                try? ctx.save()
            }
        }
        button.isEnabled = false
    }

    override func configure(for contact: Contact) {
        button.isEnabled = contact.birthday == nil
        self.contact = contact
        nameLabel.text = contact.name
        profileImageView.set(contact: contact, fromStore: store)
    }

}
