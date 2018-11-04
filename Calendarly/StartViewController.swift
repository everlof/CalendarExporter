import UIKit
import CoreData
import BLTNBoard

class StartViewController: UITabBarController {

    let titleLabel = UILabel()

    let createButton = UIButton(type: .system)

    lazy var designViewController: DesignsNavigationController = {
        let designs = DesignsNavigationController(persistentContainer: self.persistentContainer)
        designs.tabBarItem = UITabBarItem(title: "Designs", image: UIImage(named: "ic_tabbar_calendar"), selectedImage: nil)
        return designs
    }()

    lazy var birthdaysViewController: BirthdaysNavigationController = {
        let birthdays = BirthdaysNavigationController(persistentContainer: self.persistentContainer)
        birthdays.tabBarItem = UITabBarItem(title: "Birthdays", image: UIImage(named: "ic_tabbar_birthday"), selectedImage: nil)
        return birthdays
    }()

    lazy var eventsViewController: EventsNavigationController = {
        let events = EventsNavigationController(persistentContainer: self.persistentContainer)
        events.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "ic_tabbar_events"), selectedImage: nil)
        return events
    }()

    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(nibName: nil, bundle: nil)
        setViewControllers([
            designViewController,
            birthdaysViewController,
            eventsViewController
        ], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .boneWhiteColor
    }

}
