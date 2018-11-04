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

class EventsNavigationController: UINavigationController {

    let eventsViewController: EventsViewController

    init(persistentContainer: NSPersistentContainer) {
        eventsViewController = EventsViewController(persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([eventsViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class EventsViewController: UIViewController {

    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didPressAdd))
    }

    @objc func didPressAdd() {
        bulletinManager().showBulletin(above: self, animated: true, completion: nil)
    }

    func bulletinManager() -> BLTNItemManager {
        let rootPage = ChampagneViewBLTNItem(title: "Add a birthday!")
        let nameBirthdayPage = TextFieldBulletinPage(title: "Who's birthday?")
        let selectDatePage = DatePickerBLTItem(title: "And when's this birthday?")
        var name: String!

        let manager = BLTNItemManager(rootItem: rootPage)
        manager.backgroundViewStyle = .blurredDark

        // === FIRST ===
        //        rootPage.image = UIImage(named: "ic_birthdaycake")
        //        rootPage.descriptionText = "Add a birthday that will be shown in your calendars"
        rootPage.actionButtonTitle = "Let's go!"
        rootPage.actionHandler = { actionItem in
            manager.push(item: nameBirthdayPage)
        }

        rootPage.alternativeButtonTitle = "Oh, I mistapped"
        rootPage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }
        rootPage.requiresCloseButton = false

        // === SECOND -> SELECT NAME ===
        nameBirthdayPage.isDismissable = false
        nameBirthdayPage.descriptionText = "Write the name of the person you'd like to add to your calendars."
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
        selectDatePage.descriptionText = "Choose the year you'd like to create a calendar for"
        selectDatePage.requiresCloseButton = false
        selectDatePage.actionButtonTitle = "Done"
        selectDatePage.actionHandler = { actionItem in
            self.persistentContainer.performBackgroundTask({ ctx in
                let birthday = NSEntityDescription.insertNewObject(forEntityName: Birthday.self.description(), into: ctx) as! Birthday
                birthday.name_ = name.replacingOccurrences(of: " ", with: "")

                let group = DispatchGroup()
                var comp = DateComponents()
                group.enter()
                DispatchQueue.main.async {
                    comp = Calendar.current.dateComponents([.year, .month, .day], from: selectDatePage.containerView.datePicker.date)
                    group.leave()
                }
                group.wait()

                birthday.year_  = Int16(comp.year ?? 0)
                birthday.month_ = Int16(comp.month ?? 1)
                birthday.day_ = Int16(comp.day ?? 1)
                try? ctx.save()
            })
            manager.dismissBulletin(animated: true)
        }
        selectDatePage.alternativeButtonTitle = "Cancel"
        selectDatePage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }

        return manager
    }

}
