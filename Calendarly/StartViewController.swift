import UIKit
import CoreData
import BLTNBoard

class StartViewController: UITabBarController {

    let titleLabel = UILabel()

    let createButton = UIButton(type: .system)

    lazy var designViewController: DesignsNavigationController = {
        return DesignsNavigationController(persistentContainer: self.persistentContainer)
    }()

    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(nibName: nil, bundle: nil)
        setViewControllers([designViewController], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .boneWhiteColor

//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(titleLabel)
//
//        createButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(createButton)
//
//        createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        createButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
//
//        let attrText = NSMutableAttributedString(string: "Calendarly", attributes: [
//            NSAttributedStringKey.kern: -2.0,
//            NSAttributedStringKey.font: UIFont(name: "ArialRoundedMTBold", size: 58) as Any,
//            NSAttributedStringKey.foregroundColor: UIColor.greenMatchingBone
//        ])
//
//        titleLabel.attributedText = attrText
//
//        createButton.setTitle("Skapa calender", for: .normal)
//        createButton.setTitleColor(.purpleMatchingBone, for: .normal)
//        createButton.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 20)
//        createButton.addTarget(self, action: #selector(createCalendar), for: .touchUpInside)
    }

}
