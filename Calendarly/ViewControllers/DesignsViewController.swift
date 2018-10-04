import UIKit
import CoreData
import MBProgressHUD
import BLTNBoard

class DesignsNavigationController: UINavigationController {

    let designsViewController: DesignsViewController

    init(persistentContainer: NSPersistentContainer) {
        designsViewController = DesignsViewController(persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([designsViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DesignsViewController: UIViewController {

    let collectionView: DesignsCollectionView

    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        collectionView = DesignsCollectionView(persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)
        collectionView.designsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAdd))

        title = "Designs"
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        collectionView.layout.minimumLineSpacing = 6
        collectionView.layout.minimumInteritemSpacing = 12
        collectionView.sectionInsets = UIEdgeInsets(top: collectionView.layout.minimumInteritemSpacing,
                                                    left: collectionView.layout.minimumInteritemSpacing,
                                                    bottom: collectionView.layout.minimumInteritemSpacing,
                                                    right: collectionView.layout.minimumInteritemSpacing)

        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.needUpdateSizes()
    }

    @objc func didPressAdd() {
//        persistentContainer.performBackgroundTask { ctx in
//            let design = Design.createIn(context: ctx)
//            try! ctx.save()
//            DispatchQueue.main.async {
//                let vc = DesignNavigationController(design: self.persistentContainer.viewContext.object(with: design.objectID) as! Design)
//                self.present(vc, animated: true, completion: nil)
//            }
//        }

        bulletinManager.showBulletin(above: self, animated: true, completion: nil)
    }

    lazy var bulletinManager: BLTNItemManager = {
        let rootPage = FeedbackPageBLTNItem(title: "New design")
        let nameDesignPage = TextFieldBulletinPage(title: "Name your design")
        let selectYearPage = YearPickerBLTNItem(title: "Which year?")

        var name: String?
        var year: Int?

        let manager = BLTNItemManager(rootItem: rootPage)
        manager.backgroundViewStyle = .blurredDark

        // === FIRST ===
        rootPage.image = UIImage(named: "ic_calendar")
        rootPage.descriptionText = "Style your calendar, exactly the way you like it"
        rootPage.actionButtonTitle = "Let's do it!"
        rootPage.actionHandler = { actionItem in
            manager.push(item: nameDesignPage)
        }

        rootPage.alternativeButtonTitle = "Oh, I mistapped"
        rootPage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }
        rootPage.requiresCloseButton = false

        // === SECOND -> SELECT NAME ===
        nameDesignPage.isDismissable = false
        nameDesignPage.descriptionText = "To create your profile, please tell us your name. We will use it to customize your feed."
        nameDesignPage.textInputHandler = { (item, text) in
            name = text
        }
        nameDesignPage.requiresCloseButton = false
        nameDesignPage.actionButtonTitle = "Next"
        nameDesignPage.actionHandler = { actionItem in
            manager.push(item: selectYearPage)
        }
        nameDesignPage.alternativeButtonTitle = "Cancel"
        nameDesignPage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }

        // === THIRD -> SELECT YEAR ===
        selectYearPage.descriptionText = "Choose the year you'd like to create a calendar for"
        selectYearPage.requiresCloseButton = false
        selectYearPage.actionHandler = { actionItem in
            year = Int(selectYearPage.containerView.stepper.value)
            self.persistentContainer.performBackgroundTask({ ctx in
                let design = Design.createIn(context: ctx)
                design.name = name
                design.year = Int16(year!)
                try? ctx.save()
            })
            manager.dismissBulletin(animated: true)
        }
        selectYearPage.alternativeButtonTitle = "Cancel"
        selectYearPage.alternativeHandler = { actionItem in
            manager.dismissBulletin()
        }

        return manager
    }()

}

extension DesignsViewController: DesignsCollectionViewDelegate {

    func present(design: Design) {
        present(DesignNavigationController(design: design), animated: true, completion: nil)
    }

}
