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

import Contacts
import CoreData
import DZNEmptyDataSet
import UIKit

class ContactListViewController: PageViewControllerChild,
    UITableViewDelegate,
    DZNEmptyDataSetDelegate,
    DZNEmptyDataSetSource {

    let style: BirthdaysViewController.Style

    lazy var tableView = UITableView()

    lazy var store = CNContactStore()

    let model: ContactModel

    let context: NSManagedObjectContext

    var frc: NSFetchedResultsController<Contact>!

    var frcDelegate: FetchedResultsControllerDelegate<Contact, ContactCell>!

    init(style: BirthdaysViewController.Style, index: Int, context: NSManagedObjectContext) {
        self.style = style
        self.context = context
        model = ContactModel(context: context)
        super.init(index: index)
        model.update()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(index: Int) {
        fatalError("init(index:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = .boneConstrastDarkest
        tableView.backgroundColor = .boneWhiteColor
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true


        let fr = NSFetchRequest<Contact>(entityName: Contact.self.description())
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Contact.name, ascending: true)
        ]

        frc = NSFetchedResultsController(fetchRequest: fr,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)

        frcDelegate = FetchedResultsControllerDelegate(controller: frc, tableView: tableView, delegate: self)
        frcDelegate.cellHeight = 60
        frcDelegate.preConfigureCellClosure = { cell, _ in
            cell.style = self.style
        }

        do {
            try frcDelegate.fetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch style {
        case .inDesign:
            return indexPath
        case .standalone:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case let .inDesign(design) = style {
            let contact = frc.object(at: indexPath)
            if contact.designs?.contains(design) == .some(true) {
                contact.removeFromDesigns(design)
            } else {
                contact.addToDesigns(design)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            return nil
        case .denied:
            return NSAttributedString(string: "No access", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
            ])
        case .notDetermined:
            return NSAttributedString(string: "Grant access", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
            ])
        case .restricted:
            return NSAttributedString(string: "Contacts restricted", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
            ])
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            return nil
        case .denied:
            return NSAttributedString(string: "It looks like you've denied access to contacts. If you want to use birthdays from your contacts, press the button below to go to settings.", attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
            ])
        case .notDetermined:
            return NSAttributedString(string: "You've not yet granted access, press the button below to grant access.", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
            ])
        case .restricted:
            return NSAttributedString(string: "It appears that there are some restrictions on this device that that makes this app unable to grant access to your contacts.", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
            ])
        }
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .restricted:
            return nil
        case .denied, .notDetermined:
            return NSAttributedString(string: "Grant access", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
            ])
        }
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .restricted:
            break
        case .denied:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        case .notDetermined:
            store.requestAccess(for: .contacts) { (access, error) in self.tableView.reloadData() }
        }
    }

}
