import Foundation
import UIKit

class PRV300DPIPrintRenderer: UIPrintPageRenderer {
    func pdfData() -> NSData {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
        UIColor.white.set()
        let pdfContext = UIGraphicsGetCurrentContext()!
        pdfContext.saveGState()
        // scale down to improve dpi from screen 72dpi to printable 300dpi
        pdfContext.concatenate(CGAffineTransform.identity.scaledBy(x: 72/300, y: 72/300))
        prepare(forDrawingPages: NSRange(0...numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0..<self.numberOfPages {
            UIGraphicsBeginPDFPage();
            drawPage(at: i, in: bounds)
        }
        pdfContext.restoreGState()
        UIGraphicsEndPDFContext();
        return data
    }
}
