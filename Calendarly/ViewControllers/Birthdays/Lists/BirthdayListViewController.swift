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

    let style: BirthdaysViewController.Style
    
    lazy var tableView = UITableView()

    lazy var store = CNContactStore()

    let context: NSManagedObjectContext

    var frc: NSFetchedResultsController<Birthday>!

    var frcDelegate: FetchedResultsControllerDelegate<Birthday, BirthdayCell>!

    init(style: BirthdaysViewController.Style, index: Int, context: NSManagedObjectContext) {
        self.style = style
        self.context = context
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
            NSSortDescriptor(keyPath: \Birthday.name_, ascending: true)
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
            let birthday = frc.object(at: indexPath)
            if birthday.designs?.contains(design) == .some(true) {
                birthday.removeFromDesigns(design)
            } else {
                birthday.addToDesigns(design)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Add a birthday", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
        ])
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Add your first birthday by pressing the plus icon at the top of the screen.", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.boneConstrastDarkest
        ])
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ic_tabbar_birthday_large")!
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.boneConstrastDarkest
    }

}
