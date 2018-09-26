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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { ctx in
            self.stackView.arrangedSubviews[1].isHidden = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        }, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        view.addSubview(stackView)

        stackView.spacing = 1
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        addContentController(calendarPreviewer, to: stackView)
        addContentController(styleController, to: stackView)
        stackView.arrangedSubviews[1].isHidden = UIScreen.main.bounds.height > UIScreen.main.bounds.width
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarPreviewer.reload()
    }

}

