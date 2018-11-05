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
import CoreData
import Contacts

class ContactModel {

    lazy var store = CNContactStore()

    let context: NSManagedObjectContext

    lazy var contactFormatter: CNContactFormatter = {
        let frm = CNContactFormatter()
        frm.style = .fullName
        return frm
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func update() {
        let fetchRequest = CNContactFetchRequest(keysToFetch: [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactRelationsKey as CNKeyDescriptor,
            CNContactNicknameKey as CNKeyDescriptor
            ])

        do {
            let ctx = context.childContext(concurrencyType: .mainQueueConcurrencyType)
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, isCompleted) in

                // First - if there's no birthday, don't save.
                // And if the birthday was removed - we'll remove our reference too.
                guard contact.birthday != nil else {
                    let fetchRequest = NSFetchRequest<Contact>(entityName: Contact.self.description())
                    fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Contact.calendarIdentifier), contact.identifier)

                    if case let toDelete?? = try? ctx.fetch(fetchRequest).first {
                        ctx.delete(toDelete)
                        try? ctx.save()
                    }

                    return
                }

                let fetchRequest = NSFetchRequest<Contact>(entityName: Contact.self.description())
                fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Contact.calendarIdentifier), contact.identifier)

                ctx.performAndWait {
                    if case let localContact?? = try? ctx.fetch(fetchRequest).first {
                        print("Updating \(self.contactFormatter.string(from: contact)), identifier=\(contact.identifier)")
                        localContact.name_ = self.contactFormatter.string(from: contact)
                        localContact.day = Int16(contact.birthday?.day ?? 0)
                        localContact.month = Int16(contact.birthday?.month ?? 0)
                        localContact.year = Int16(contact.birthday?.year ?? 0)
                    } else {
                        print("Inserted \(self.contactFormatter.string(from: contact)), identifier=\(contact.identifier)")
                        let localContact = NSEntityDescription.insertNewObject(forEntityName: Contact.self.description(), into: ctx) as! Contact
                        localContact.name_ = self.contactFormatter.string(from: contact)
                        localContact.day = Int16(contact.birthday?.day ?? 0)
                        localContact.month = Int16(contact.birthday?.month ?? 0)
                        localContact.year = Int16(contact.birthday?.year ?? 0)
                        localContact.calendarIdentifier = contact.identifier
                    }

                    try? ctx.save()
                }
            })
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}
