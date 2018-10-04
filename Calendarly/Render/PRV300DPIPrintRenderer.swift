import Foundation
import UIKit
import GBDeviceInfo

class PRV300DPIPrintRenderer: UIPrintPageRenderer {

    func pdfData() -> NSData {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
        UIColor.white.set()
        let pdfContext = UIGraphicsGetCurrentContext()!
        pdfContext.saveGState()

        if let pixelsPerInch = GBDeviceInfo.deviceInfo()?.displayInfo.pixelsPerInch {
            pdfContext.concatenate(CGAffineTransform.identity.scaledBy(x: pixelsPerInch/300, y: pixelsPerInch/300))
        }

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
