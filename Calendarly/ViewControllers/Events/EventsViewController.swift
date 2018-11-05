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

import BLTNBoard
import CoreData
import UIKit
import DZNEmptyDataSet

class EventsNavigationController: UINavigationController {

    let eventsViewController: EventsViewController

    init(style: BirthdaysViewController.Style, context: NSManagedObjectContext, persistentContainer: NSPersistentContainer) {
        eventsViewController = EventsViewController(style: style,
                                                    context: context,
                                                    persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([eventsViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class EventsViewController: UIViewController,
    UITableViewDelegate,
    DZNEmptyDataSetDelegate,
    DZNEmptyDataSetSource {

    let context: NSManagedObjectContext

    let persistentContainer: NSPersistentContainer

    let style: BirthdaysViewController.Style

    lazy var tableView = UITableView()

    var frc: NSFetchedResultsController<Event>!

    var frcDelegate: FetchedResultsControllerDelegate<Event, EventCell>!

    init(style: BirthdaysViewController.Style,
         context: NSManagedObjectContext,
         persistentContainer: NSPersistentContainer) {
        self.style = style
        self.persistentContainer = persistentContainer
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = UIColor.boneWhiteColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didPressAdd))

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

        let fr = NSFetchRequest<Event>(entityName: Event.self.description())
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.text, ascending: true)
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

    @objc func didPressAdd() {
        bulletinManager().showBulletin(above: self, animated: true, completion: nil)
    }

    func bulletinManager() -> BLTNItemManager {
        let rootPage = ChampagneViewBLTNItem(title: "Add something to celebrate!")
        let occurancePage = OccuranceSelectorBulletinPage(title: "")
        let nameBirthdayPage = TextFieldBulletinPage(title: "What")
        nameBirthdayPage.placeholder = "What to celebrate"
        let selectDatePage = DatePickerBLTItem(title: "And when is it?")
        var name: String!

        let manager = BLTNItemManager(rootItem: rootPage)
        manager.backgroundViewStyle = .blurredDark

        // === FIRST ===
        rootPage.actionButtonTitle = "Let's go!"
        rootPage.actionHandler = { actionItem in
            manager.push(item: occurancePage)
        }

        rootPage.alternativeButtonTitle = "Oh, I mistapped"
        rootPage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }
        rootPage.requiresCloseButton = false

        // === SECOND -> SELECT ONCE/RECURRING ===
        occurancePage.actionButtonTitle = "Next"
        occurancePage.descriptionText = "Does the event happen once, like a graduation or is it recurring like a wedding anniversary?"
        occurancePage.isDismissable = false
        occurancePage.requiresCloseButton = false
        occurancePage.next = nameBirthdayPage
        occurancePage.actionHandler = { _ in
            manager.push(item: nameBirthdayPage)
        }

        // === THIRD -> SELECT YEAR ===
        nameBirthdayPage.isDismissable = false
        nameBirthdayPage.descriptionText = "What whould you like to celebrate? This text will appear in the calendar."
        nameBirthdayPage.textInputHandler = { (item, text) in
            name = text
        }
        nameBirthdayPage.requiresCloseButton = false
        nameBirthdayPage.actionButtonTitle = "Next"
        nameBirthdayPage.actionHandler = { actionItem in
            manager.push(item: selectDatePage)
        }
        nameBirthdayPage.alternativeButtonTitle = "Cancel"
        nameBirthdayPage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }

        // === THIRD -> SELECT YEAR ===
        selectDatePage.descriptionText = "Choose the date the event occur"
        selectDatePage.requiresCloseButton = false
        selectDatePage.actionButtonTitle = "Done"
        selectDatePage.actionHandler = { actionItem in
            self.persistentContainer.performBackgroundTask { context in
                let event = NSEntityDescription.insertNewObject(forEntityName: Event.self.description(), into: self.context) as! Event
                event.text = name.replacingOccurrences(of: " ", with: "")
                event.reoccurring = !(occurancePage.isOnce ?? true)

                let group = DispatchGroup()
                var comp = DateComponents()
                group.enter()
                DispatchQueue.main.async {
                    comp = Calendar.current.dateComponents([.year, .month, .day], from: selectDatePage.containerView.datePicker.date)
                    group.leave()
                }
                group.wait()

                event.year_  = Int16(comp.year ?? 0)
                event.month_ = Int16(comp.month ?? 1)
                event.day_ = Int16(comp.day ?? 1)
                try? self.context.save()
            }
            manager.dismissBulletin(animated: true)
        }
        selectDatePage.alternativeButtonTitle = "Cancel"
        selectDatePage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }

        return manager
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
            let event = frc.object(at: indexPath)
            if event.designs?.contains(design) == .some(true) {
                event.removeFromDesigns(design)
            } else {
                event.addToDesigns(design)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
