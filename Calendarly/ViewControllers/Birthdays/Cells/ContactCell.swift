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

class EditButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setImage(UIImage(named: "ic_edit")!, for: .normal)
        layer.borderWidth = 1/UIScreen.main.scale
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 36, height: 36)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ContactCell: FRCCell<Contact> {

    var contact: Contact?

    let profileImageView = ProfileImageView()

    let nameLabel = UILabel()

    let descriptionlabel = UILabel()

    lazy var store = CNContactStore()

    var style: BirthdaysViewController.Style = .standalone

    let editButton = EditButton()

    weak var presenter: UIViewController?

    weak var persistentContainer: NSPersistentContainer?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .boneContrastLighter

        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionlabel)
        contentView.addSubview(editButton)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionlabel.translatesAutoresizingMaskIntoConstraints = false

        profileImageView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 42).isActive = true

        profileImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 9).isActive = true

        descriptionlabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        descriptionlabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(didPress), for: .touchUpInside)
        editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didPress() {
        guard let contact = contact else { return }
        guard let identifier = contact.calendarIdentifier else { return }

        let formatter = CNContactFormatter()

        guard case let contactWithNames? = try? store.unifiedContact(withIdentifier: identifier, keysToFetch: [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactNicknameKey as CNKeyDescriptor
        ]) else { return }

        var alternatives: [String] = [
            formatter.string(from: contactWithNames) ?? "John Doe",
        ]

        if !contactWithNames.nickname.isEmpty {
            alternatives.append(contactWithNames.nickname)
        }

        if !contactWithNames.givenName.isEmpty {
            alternatives.append(contactWithNames.givenName)
        }

        if !contactWithNames.givenName.isEmpty && !contactWithNames.familyName.isEmpty {
            alternatives.append("\(contactWithNames.givenName) \(contactWithNames.familyName.first!)")
        }

        alternatives = Array(Set<String>(alternatives)).sorted(by: { lhs, rhs in
            return lhs.count < rhs.count
        })

        let alertController = UIAlertController(title: "Select visible name", message: nil, preferredStyle: .actionSheet)

        alternatives.forEach { alternative in
            let action = UIAlertAction(title: alternative, style: .default, handler: { _ in
                let objectID = contact.objectID
                self.persistentContainer?.performBackgroundTask { context in
                    let contactInContext = context.object(with: objectID) as! Contact
                    contactInContext.customName = alternative
                    try? context.save()
                }
            })
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        presenter?.present(alertController, animated: true, completion: nil)
    }

    override func configure(for contact: Contact) {
        switch style {
        case .inDesign(let design):
            selectionStyle = .gray
            accessoryType = contact.designs?.contains(design) == .some(true) ? .checkmark : .none
        case .standalone:
            selectionStyle = .none
        }

        descriptionlabel.text = contact.calendarEvent.description
        self.contact = contact
        nameLabel.text = contact.name
        profileImageView.set(contact: contact, fromStore: store)
    }

}
