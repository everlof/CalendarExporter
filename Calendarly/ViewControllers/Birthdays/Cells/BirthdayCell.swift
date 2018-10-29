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

class BirthdayCell: BasePersonCell<Birthday> {

    var birthday: Birthday?

    weak var presenter: UIViewController?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        button.addTarget(self, action: #selector(didPress), for: .touchUpInside)
        button.setTitle("Remove", for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    @objc func didPress() {
        guard let objectID = self.birthday?.objectID else { fatalError("No `objectID` for removed birthday") }

        let performDelete = {
            self.persistentContainer?.performBackgroundTask { ctx in
                ctx.delete(ctx.object(with: objectID))
                try? ctx.save()
            }
        }

        if birthday?.source == .some(.created) {
            guard let name = self.birthday?.name else { fatalError("No `name` for removed birthday") }

            let confirmController =
                UIAlertController(title: "Delete \(name)'s birthday?",
                    message: "Are you sure you want to permanently remove \(name)'s birthday?",
                    preferredStyle: .alert)

            confirmController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.button.isEnabled = false
                performDelete()
            }))
            confirmController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            presenter?.present(confirmController, animated: true, completion: nil)
        } else {
            self.button.isEnabled = false
            profileImageView.takeOff(with: FlyingView.contact) {
                performDelete()
            }
        }
    }

    override func configure(for birthday: Birthday) {
        super.configure(for: birthday)
        button.isEnabled = true
        self.birthday = birthday
        nameLabel.text = birthday.name
        if let contact = birthday.contact {
            profileImageView.set(contact: contact, fromStore: store)
        } else {
            profileImageView.setPlaceholderImage()
        }
    }

}
