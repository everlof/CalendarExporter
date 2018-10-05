import UIKit

class HTMLCalendarPreviewController: UIViewController, HTMLCalendarDelegate {

//    let webView = UIWebView()
//
//    let calendar: HTMLCalendar
//
//    var renderer: HTMLCalendarRenderer!

//    var webViewInset: UIEdgeInsets = .zero {
//        didSet {
//            leftConstraint.constant = webViewInset.left
//            rightConstraint.constant = -webViewInset.right
//            topConstraint.constant = webViewInset.top
//        }
//    }
//
//    var webViewBorder: Bool = false {
//        didSet {
//            if webViewBorder {
//                webView.layer.borderWidth = 1 / UIScreen.main.scale
//                webView.layer.borderColor = UIColor.boneConstrastDarker.cgColor
//            } else {
//                webView.layer.borderWidth = 0.0
//            }
//        }
//    }

    var leftConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!

    let calendarView: CalendarView

    init(design: Design) {
        calendarView = CalendarView(design: design)
        super.init(nibName: nil, bundle: nil)
//        self.calendar.delegate = self
//        webView.isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .boneWhiteColor // UIColor(red: 0xDD/0xFF, green: 0xDD/0xFF, blue: 0xDD/0xFF, alpha: 0xFF)

//        webView.isOpaque = false
//        webView.backgroundColor = .white

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

    func reload() {
//        heightContraint.constant = ((view.frame.width - webViewInset.left - webViewInset.right) * 1.41428571)
//        webView.loadHTMLString(calendar.export(), baseURL: nil)
    }

    // MARK: - HTMLCalendarDelegate

    func contentDidChange() {
        reload()
    }


}
