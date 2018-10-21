import UIKit

class HTMLCalendarPreviewController: UIViewController {

    var leftConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!

    let calendarView: CalendarView

    init(design: Design) {
        calendarView = CalendarView(design: design)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .boneWhiteColor // UIColor(red: 0xDD/0xFF, green: 0xDD/0xFF, blue: 0xDD/0xFF, alpha: 0xFF)

        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false

        leftConstraint = calendarView.leftAnchor.constraint(equalTo: view.leftAnchor)
        leftConstraint.isActive = true

        topConstraint = calendarView.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint.isActive = true

        rightConstraint = calendarView.rightAnchor.constraint(equalTo: view.rightAnchor)
        rightConstraint.isActive = true

        heightContraint = calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        heightContraint.isActive = true
    }

}
