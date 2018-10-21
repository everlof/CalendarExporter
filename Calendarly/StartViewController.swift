import UIKit
import CoreData
import BLTNBoard

class StartViewController: UITabBarController {

    let titleLabel = UILabel()

    let createButton = UIButton(type: .system)

    lazy var designViewController: DesignsNavigationController = {
        return DesignsNavigationController(persistentContainer: self.persistentContainer)
    }()

    lazy var birthdaysViewController: BirthdaysNavigationController = {
        return BirthdaysNavigationController(persistentContainer: self.persistentContainer)
    }()

    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(nibName: nil, bundle: nil)
        setViewControllers([
            designViewController,
            birthdaysViewController
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
