import Foundation
import UIKit

extension UIWebView {

    func export(size: CGSize) -> NSData {
        let renderer = PRV300DPIPrintRenderer()
        let formatter = viewPrintFormatter()
        formatter.perPageContentInsets = .zero
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        let topPadding: CGFloat = 0 // 115.0
        let bottomPadding: CGFloat = 0 // 117.0
        let leftPadding: CGFloat = 0 // 100.0
        let rightPadding: CGFloat = 0 // 100.0

        let printableRect = CGRect(x: leftPadding,
                                   y: topPadding,
                                   width: size.width - leftPadding - rightPadding,
                                   height: size.height - topPadding - bottomPadding)

        let paperRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        return renderer.pdfData()
    }

}
