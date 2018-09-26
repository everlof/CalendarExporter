import UIKit

class HTMLCalendarPreviewController: UIViewController, HTMLCalendarDelegate {

    let webView = UIWebView()

    var heightContraint: NSLayoutConstraint!

    let calendar: HTMLCalendar

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

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        heightContraint = webView.heightAnchor.constraint(equalToConstant: 100)
        heightContraint.isActive = true

//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.reload()
//        }
    }

    func reload() {
        heightContraint.constant = view.frame.width * 1.41428571
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
