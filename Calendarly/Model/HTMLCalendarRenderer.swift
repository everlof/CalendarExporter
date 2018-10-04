import UIKit

class HTMLCalendarRenderer: NSObject, UIWebViewDelegate {

    let calendar: HTMLCalendar

    let page: Int?

    init(calendar: HTMLCalendar, page: Int? = nil) {
        self.calendar = calendar
        self.page = page
        super.init()
        retainCycle = self
    }

    var webView: UIWebView!

    var completed: ((UIImage?) -> Void)!

    var retainCycle: HTMLCalendarRenderer!

    func snap(completed: @escaping ((UIImage?) -> Void)) {
        print("Snap")
        let width: CGFloat = 300
        let rect = CGRect(x: 0, y: 0, width: width, height: width * 1.41428571)

        self.completed = completed
        webView = UIWebView(frame: rect)
        webView.delegate = self
        webView.loadHTMLString(calendar.export(month: page), baseURL: nil)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.webView = nil
        print("Failed with: \(error)")
        retainCycle = nil
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Start load!")
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Finish load!")
        self.completed(webView.snapshot)
        self.webView = nil
        retainCycle = nil
    }

}

