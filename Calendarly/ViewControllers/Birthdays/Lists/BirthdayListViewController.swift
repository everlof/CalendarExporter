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

class BirthdayListViewController: PageViewControllerChild,
    UITableViewDelegate,
    DZNEmptyDataSetDelegate,
    DZNEmptyDataSetSource {
    
    lazy var tableView = UITableView()

    lazy var store = CNContactStore()

    let persistentContainer: NSPersistentContainer

    var frc: NSFetchedResultsController<Birthday>!

    var frcDelegate: FetchedResultsControllerDelegate<Birthday, BirthdayCell>!

    init(index: Int, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(index: index)
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
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let fr = NSFetchRequest<Birthday>(entityName: Birthday.self.description())
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Birthday.contact?.name, ascending: true)
        ]

        frc = NSFetchedResultsController(fetchRequest: fr,
                                         managedObjectContext: persistentContainer.viewContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)

        frcDelegate = FetchedResultsControllerDelegate(controller: frc, tableView: tableView, delegate: self)
        frcDelegate.cellHeight = 80
        frcDelegate.preConfigureCellClosure = { cell, _ in
            cell.persistentContainer = self.persistentContainer
        }

        do {
            try frcDelegate.fetch()
        } catch {
            print(error.localizedDescription)
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
