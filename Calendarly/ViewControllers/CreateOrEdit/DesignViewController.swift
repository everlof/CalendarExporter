import UIKit
import CoreData
import MBProgressHUD

extension UIViewController {

    func addContentController(_ child: UIViewController, to stackView: UIStackView) {
        addChild(child)
        stackView.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }

}

class DesignNavigationController: UINavigationController {

    let styleViewController: DesignViewController

    init(design: Design) {
        self.styleViewController = DesignViewController(design: design)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([styleViewController], animated: true)
    }

}

class DesignViewController: UIViewController {

    let calendarPreviewer: HTMLCalendarPreviewController

    lazy var styleController: HTMLCalendarStylerViewController = {
        return HTMLCalendarStylerViewController(previewController: self.calendarPreviewer)
    }()

    let stackView = UIStackView()

    let tiltToPreviewView = UIStackView()

    let titltToPreviewImage = UIImageView()

    var topConstraint: NSLayoutConstraint!

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

    init(design: Design) {
        editingContext = design.managedObjectContext!.childContext(concurrencyType: .mainQueueConcurrencyType)
        self.design = editingContext.object(with: design.objectID) as! Design
        calendarPreviewer = HTMLCalendarPreviewController(calendar: HTMLCalendar(design: self.design))
        super.init(nibName: nil, bundle: nil)

        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTap))

        navigationItem.title = "Inställningar"

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(didPressSave))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didPressExport))
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

    @objc func didPressSave() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didPressExport() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Exporting PDF"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            CalendarBook(design: self.design, size: .A3).startPrinting { url in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { ctx in self.adjustLayout() }, completion: nil)
    }

    func adjustLayout() {
        let portrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        self.stackView.arrangedSubviews[1].isHidden = portrait
        self.topConstraint.constant = portrait ? 24 : 0
        tiltToPreviewView.isHidden = !portrait

        if portrait {
            navigationController?.setNavigationBarHidden(!navigationBarVisibleInPortrait, animated: false)
            calendarPreviewer.webViewInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
            calendarPreviewer.webViewBorder = true
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
            calendarPreviewer.webViewInset = .zero
            calendarPreviewer.webViewBorder = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupAnimation),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        view.backgroundColor = .boneWhiteColor
        view.addSubview(stackView)

        stackView.spacing = 1

        stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        topConstraint = stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        topConstraint.isActive = true

        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        addContentController(calendarPreviewer, to: stackView)
        addContentController(styleController, to: stackView)
        stackView.arrangedSubviews[1].isHidden = UIScreen.main.bounds.height > UIScreen.main.bounds.width

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
        calendarPreviewer.reload()
        setupAnimation()
    }

}
