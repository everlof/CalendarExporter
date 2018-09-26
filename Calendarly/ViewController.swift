import UIKit

extension UIViewController {

    func addContentController(_ child: UIViewController, to stackView: UIStackView) {
        addChildViewController(child)
        stackView.addArrangedSubview(child.view)
        child.didMove(toParentViewController: self)
    }

}

class ViewController: UIViewController {

    lazy var calendarPreviewer: HTMLCalendarPreviewController = {
        return HTMLCalendarPreviewController(calendar: HTMLCalendar(year: 2018, locale: .current))
    }()

    lazy var styleController: HTMLCalendarStylerNavigationController = {
        return HTMLCalendarStylerNavigationController(previewController: self.calendarPreviewer)
    }()

    let stackView = UIStackView()

    let tiltToPreviewView = UIStackView()

    let titltToPreviewImage = UIImageView()

    var topConstraint: NSLayoutConstraint!

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { ctx in self.adjustLayout() }, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func adjustLayout() {
        let portrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        self.stackView.arrangedSubviews[1].isHidden = portrait
        self.topConstraint.constant = portrait ? 50 : 0
        tiltToPreviewView.isHidden = !portrait

        if portrait {
            calendarPreviewer.webViewInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
            calendarPreviewer.webViewBorder = true
        } else {
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
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        view.backgroundColor = .boneWhiteColor
        view.addSubview(stackView)

        stackView.spacing = 1
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        topConstraint = stackView.topAnchor.constraint(equalTo: view.topAnchor)
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

