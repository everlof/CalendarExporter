import UIKit
import CoreData

class DesignViewController: UIViewController, UITextFieldDelegate {

    let calendarView: CalendarView

    lazy var styleController: HTMLCalendarStylerNavigationController = {
        return HTMLCalendarStylerNavigationController(design: self.design, editingContext: self.editingContext, calendarView: self.calendarView)
    }()

    let tiltToPreviewView = UIStackView()

    let titltToPreviewImage = UIImageView()

    class SeparatorView: UIView {
        override var intrinsicContentSize: CGSize {
            return CGSize(width: 1/UIScreen.main.scale, height: UIView.noIntrinsicMetric)
        }
    }

    let separatorView = SeparatorView()

    let design: Design

    let editingContext: NSManagedObjectContext

    var navigationBarVisibleInPortrait: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "navigationBarHiddenInPortrait")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "navigationBarHiddenInPortrait")
            UserDefaults.standard.synchronize()
        }
    }

    let tapGesture = UITapGestureRecognizer()

    @objc func tap() {
        let textField = UITextField(frame: .zero)
        textField.text = design.name?.trimmingCharacters(in: .whitespaces)
        textField.sizeToFit()
        textField.returnKeyType = .done
        navigationItem.titleView = textField
        textField.delegate = self
        textField.becomeFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.sizeToFit()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
            design.name = textField.text
            titleButtonItem.setTitle((design.name?.trimmingCharacters(in: .whitespaces)).map { "\($0), \(design.year)" }, for: .normal)
        }
        navigationItem.titleView = titleButtonItem
        return false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    lazy var titleButtonItem: UIButton = {
        let titleButtonItem = UIButton(type: .system)
        titleButtonItem.setTitle((design.name?.trimmingCharacters(in: .whitespaces)).map { "\($0), \(design.year)" }, for: .normal)
        titleButtonItem.sizeToFit()
        titleButtonItem.addTarget(self, action: #selector(tap), for: .touchUpInside)
        return titleButtonItem
    }()

    init(design: Design) {
        editingContext = design.managedObjectContext!.childContext(concurrencyType: .mainQueueConcurrencyType)
        self.design = editingContext.object(with: design.objectID) as! Design
        calendarView = CalendarView(design: self.design)
        super.init(nibName: nil, bundle: nil)

        //view.addGestureRecognizer(tapGesture)
        //tapGesture.addTarget(self, action: #selector(didTap))

        navigationItem.titleView = titleButtonItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap() {
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            navigationBarVisibleInPortrait.toggle()
            navigationController?.setNavigationBarHidden(!navigationBarVisibleInPortrait, animated: true)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { ctx in self.adjustLayout() }, completion: nil)
    }

    func adjustLayout() {
        let portrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width

        if portrait {
            calendarView.hasBorder = true
            landscapeConstraints.forEach { $0.isActive = false }
            portraitConstraints.forEach { $0.isActive = true }
        } else {
            calendarView.hasBorder = false
            portraitConstraints.forEach { $0.isActive = false }
            landscapeConstraints.forEach { $0.isActive = true }
        }

        tiltToPreviewView.isHidden = !portrait

        if portrait {
            navigationController?.setNavigationBarHidden(!navigationBarVisibleInPortrait, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLayout()
    }

    var portraitConstraints = [NSLayoutConstraint]()

    var landscapeConstraints = [NSLayoutConstraint]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .boneWhiteColor

        view.addSubview(calendarView)

        addChild(styleController)
        view.addSubview(styleController.view)

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)

        styleController.didMove(toParent: self)
        styleController.view.translatesAutoresizingMaskIntoConstraints = false

        portraitConstraints.append(contentsOf: [
            calendarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            calendarView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85 * sqrt(2)),

            calendarView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        landscapeConstraints.append(contentsOf: [
            calendarView.widthAnchor.constraint(equalTo: calendarView.heightAnchor, multiplier: 1/sqrt(2)),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            calendarView.rightAnchor.constraint(equalTo: separatorView.leftAnchor),
            separatorView.topAnchor.constraint(equalTo: view.topAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            styleController.view.leftAnchor.constraint(equalTo: separatorView.rightAnchor),

            styleController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            styleController.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            styleController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            NSLayoutConstraint.activate(portraitConstraints)
            calendarView.hasBorder = true
            separatorView.isHidden = false
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
            calendarView.hasBorder = false
            separatorView.isHidden = true
        }

        let tiltToPreviewInstructionLabel = UILabel()
        tiltToPreviewInstructionLabel.text = "Rotate to edit"
        tiltToPreviewInstructionLabel.font = UIFont(name: "ArialRoundedMTBold", size: 18)
        tiltToPreviewInstructionLabel.textColor = .boneConstrastDarkest

        titltToPreviewImage.image = #imageLiteral(resourceName: "icon")
        titltToPreviewImage.tintColor = .boneConstrastDarkest
        titltToPreviewImage.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7)

        tiltToPreviewView.axis = .horizontal
        tiltToPreviewView.spacing = 6
        tiltToPreviewView.addArrangedSubview(titltToPreviewImage)
        tiltToPreviewView.addArrangedSubview(tiltToPreviewInstructionLabel)

        view.addSubview(tiltToPreviewView)

        tiltToPreviewView.translatesAutoresizingMaskIntoConstraints = false
        tiltToPreviewView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tiltToPreviewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36).isActive = true
    }

    @objc func setupAnimation() {
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.titltToPreviewImage.transform = CGAffineTransform.identity
                .scaledBy(x: 0.7, y: 0.7)
                .rotated(by: CGFloat.pi/2)
        }, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimation()
    }

}
