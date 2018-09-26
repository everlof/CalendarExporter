import UIKit

class HTMLCalendarPreviewController: UIViewController, HTMLCalendarDelegate {

    let webView = UIWebView()

    let calendar: HTMLCalendar

    var webViewInset: UIEdgeInsets = .zero {
        didSet {
            leftConstraint.constant = webViewInset.left
            rightConstraint.constant = -webViewInset.right
            topConstraint.constant = webViewInset.top
        }
    }

    var webViewBorder: Bool = false {
        didSet {
            if webViewBorder {
                webView.layer.borderWidth = 1 / UIScreen.main.scale 
                webView.layer.borderColor = UIColor.boneConstrastDarker.cgColor
            } else {
                webView.layer.borderWidth = 0.0
            }
        }
    }

    var leftConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!

    init(calendar: HTMLCalendar) {
        self.calendar = calendar
        super.init(nibName: nil, bundle: nil)
        self.calendar.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .boneWhiteColor // UIColor(red: 0xDD/0xFF, green: 0xDD/0xFF, blue: 0xDD/0xFF, alpha: 0xFF)

        webView.isOpaque = false
        webView.backgroundColor = .white

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        leftConstraint = webView.leftAnchor.constraint(equalTo: view.leftAnchor)
        leftConstraint.isActive = true

        topConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint.isActive = true

        rightConstraint = webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        rightConstraint.isActive = true

        heightContraint = webView.heightAnchor.constraint(equalToConstant: 100)
        heightContraint.isActive = true

//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.reload()
//        }
    }

    func reload() {
        // heightContraint.constant = view.frame.width * 1.41428571
        heightContraint.constant = ((view.frame.width - webViewInset.left - webViewInset.right) * 1.41428571)
        //        let url = URL(fileURLWithPath: "/Users/davideverlof/Downloads/livecal.html")
        //        let data = try! Data(contentsOf: url)
        //        let html = String(data: data, encoding: .utf8)!
        //        webView.loadHTMLString(html, baseURL: nil)

        webView.loadHTMLString(calendar.export(), baseURL: nil)
    }

    // MARK: - HTMLCalendarDelegate

    func contentDidChange() {
        reload()
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//
//        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
//            else { fatalError("Destination URL not created") }
//
//        webView.export(size: .A3).write(to: outputURL, atomically: true)
//        print("open \(outputURL.path)") // command to open the generated file
//    }

}
