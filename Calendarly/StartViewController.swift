import UIKit

class StartViewController: UIViewController {

    let titleLabel = UILabel()

    let createButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .boneWhiteColor

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)

        createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true

        let attrText = NSMutableAttributedString(string: "Calendarly", attributes: [
            NSAttributedStringKey.kern: -2.0,
            NSAttributedStringKey.font: UIFont(name: "ArialRoundedMTBold", size: 58) as Any,
            NSAttributedStringKey.foregroundColor: UIColor.greenMatchingBone
        ])

        titleLabel.attributedText = attrText

        createButton.setTitle("Skapa calender", for: .normal)
        createButton.setTitleColor(.purpleMatchingBone, for: .normal)
        createButton.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        createButton.addTarget(self, action: #selector(createCalendar), for: .touchUpInside)
    }

    @objc func createCalendar() {
        let viewController = ViewController(nibName: nil, bundle: nil)
        present(viewController, animated: true, completion: nil)
    }

}
