import UIKit
import CoreData
import MBProgressHUD

//class CustomPresentation: UIPresentationController, UIViewControllerAnimatedTransitioning {
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 5.0
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        ((transitionContext.viewController(forKey: .from) as! StartViewController).viewControllers!.first! as! DesignsNavigationController).viewControllers
//        guard
//            let fromVC = transitionContext.viewController(forKey: .from) as? StartViewController,
//            let navigationController = fromVC.viewControllers?.first as? DesignsNavigationController,
//            let designsViewController = navigationController.viewControllers.first,
//            let toVC = transitionContext.viewController(forKey: .to) as? DesignNavigationController,
//            let fromView = fromVC.view,
//            let toView = toVC.view
//        else {
//            fatalError("Not enough data.")
//        }
//
//        let containerView = transitionContext.containerView
//        let duration = transitionDuration(using: transitionContext)
//
//        let calendarView: CalendarView = toVC.viewControllers[0].view.subviews[0] as! CalendarView
//        calendarView.layoutIfNeeded()
//        let image = calendarView.snapshot
//        let imageView = UIImageView(image: image)
//
//        containerView.addSubview(imageView)
//        imageView.frame.origin.x = 100
//        imageView.frame.origin.y = 100
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            containerView.addSubview(toVC.view)
//            transitionContext.completeTransition(true)
//        }
//
//        guard let fromVC = transitionContext.viewController(forKey: .from),
//            let toVC = transitionContext.viewController(forKey: .to) as? DesignNavigationController else {
//                return transitionContext.completeTransition(false)
//        }
//
//        let calendarView: CalendarView = toVC.viewControllers[0].view.subviews[0] as! CalendarView
//
//        let containerView = transitionContext.containerView
//        containerView.addSubview(toVC.view)
//
//        let snapshowView = calendarView.snapshotView(afterScreenUpdates: true)!
//        containerView.addSubview(snapshowView)
//
//        snapshowView.frame.origin = CGPoint(x: 100, y: 100)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            transitionContext.completeTransition(true)
//        }
//    }
//
//    func animationEnded(_ transitionCompleted: Bool) {
//        print("animationEnded")
//    }
//
//}
//
//extension DesignNavigationController: UIViewControllerTransitioningDelegate {
//
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return CustomPresentation(presentedViewController: presented, presenting: presenting)
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil // return dismissed.presentationController as? CustomPresentation
//    }
//
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return presented.presentationController as? CustomPresentation
//    }
//
//}

class DesignNavigationController: UINavigationController {

    let designViewController: DesignViewController

    init(design: Design, persistentContainer: NSPersistentContainer) {
        designViewController = DesignViewController(design: design, persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([designViewController], animated: false)
//        modalPresentationStyle = .custom
//        transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DesignViewController: UIViewController {

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

    init(design: Design, persistentContainer: NSPersistentContainer) {
        editingContext = design.managedObjectContext!.childContext(concurrencyType: .mainQueueConcurrencyType)
        self.design = editingContext.object(with: design.objectID) as! Design
        calendarView = CalendarView(design: self.design, persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)



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

    @objc func didPressExport() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Exporting PDF"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let calendar = CalendarBook(design: self.design, size: .A3)
            calendar.export(completed: { url in
                MBProgressHUD.hide(for: self.view, animated: true)
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            })
        }
    }

    @objc func didPressSave() {
        try? editingContext.save()
        try? editingContext.parent?.save()
        dismiss(animated: true, completion: nil)
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
            view.addGestureRecognizer(tapGesture)
            tapGesture.addTarget(self, action: #selector(didTap))
        } else {
            view.removeGestureRecognizer(tapGesture)
        }

        navigationController?.setNavigationBarHidden(!(navigationBarVisibleInPortrait && portrait), animated: false)
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
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            calendarView.rightAnchor.constraint(equalTo: separatorView.leftAnchor),
            separatorView.topAnchor.constraint(equalTo: view.topAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            styleController.view.leftAnchor.constraint(equalTo: separatorView.rightAnchor),

            styleController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            styleController.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            styleController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            NSLayoutConstraint.activate(portraitConstraints)
            calendarView.hasBorder = true
            separatorView.isHidden = false

            view.addGestureRecognizer(tapGesture)
            tapGesture.addTarget(self, action: #selector(didTap))
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
            calendarView.hasBorder = false
            separatorView.isHidden = true
            navigationController?.setNavigationBarHidden(!navigationBarVisibleInPortrait, animated: false)
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
