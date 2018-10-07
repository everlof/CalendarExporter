import UIKit
import CoreData

enum FirstDayOfWeek {
    case sunday
    case monday
}

extension Design {

    static let dateFontSizeDefaultBordered: CGFloat = 1.5

    static let dateFontSizeDefaultNonBordered: CGFloat = 1.9

    static let headerFontSizeDefault: CGFloat = 1.9

    static let monthFontSizeDefault: CGFloat = 3.0

    static func createIn(context: NSManagedObjectContext) -> Design {
        let design = NSEntityDescription.insertNewObject(forEntityName: Design.self.description(), into: context) as! Design
        design.name = "My Second Design"
        design.created = Date()

        design.dateFontname = "ArialRoundedMTBold"
        design.dateFontsize = Float(dateFontSizeDefaultNonBordered)

        design.monthFontname = "ArialRoundedMTBold"
        design.monthFontsize = Float(monthFontSizeDefault)

        design.headerFontname = "ArialRoundedMTBold"
        design.headerFontsize = Float(headerFontSizeDefault)

        design.previewMonth = 1
        design.snapshotFilename = String(format: "%@.png", UUID().uuidString)

        return design
    }

    var dateFont: UIFont {
        get {
            return UIFont(name: dateFontname!, size: CGFloat(dateFontsize))!
        }
        set {
            dateFontname = newValue.fontName
        }
    }

    var monthFont: UIFont {
        get {
            return UIFont(name: monthFontname!, size: CGFloat(monthFontsize))!
        }
        set {
            monthFontname = newValue.fontName
        }
    }

    var headerFont: UIFont {
        get {
            return UIFont(name: headerFontname!, size: CGFloat(headerFontsize))!
        }
        set {
            headerFontname = newValue.fontName
        }
    }

    var locale: Locale {
        get {
            return Locale(identifier: localeIdentifier ?? Locale.autoupdatingCurrent.identifier)
        }
        set {
            localeIdentifier = newValue.identifier
        }
    }

    var firstDayOfWeek: FirstDayOfWeek {
        get {
            return weekStartSunday ? .sunday : .monday
        }
        set {
            weekStartSunday = newValue == .sunday
        }
    }

    var colors: [ColorCombo] {
        return (0..<13).map { i in return i % 2 == 0 ? ColorCombo.red : ColorCombo.black }
    }

    var snapshotURL: URL {
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let fullPath = (path as NSString).appendingPathComponent(snapshotFilename!)
        return URL(fileURLWithPath: fullPath)
    }

    func snapshot(callback: @escaping ((UIImage?) -> Void)) {
        // HTMLCalendarRenderer(calendar: HTMLCalendar(design: self)).snap(completed: callback)
        let height: CGFloat = 300
        let view = CalendarView(design: self, frame: CGRect(origin: .zero, size: CGSize(width: height*(1/sqrt(2)), height: height)))
        view.layoutIfNeeded()
        callback(view.snapshot)
        view.cleanUp()
    }

}

class CalendarBook: NSObject, UIWebViewDelegate {

    let design: Design

    let workfolder: String

    var done: ((URL) -> Void)!

    var retainSelf: CalendarBook!

//    var webView: UIWebView!

    var cal: HTMLCalendar!

    var currentPage: Int = 1

    let prefix = UUID().uuidString

    let size: CGSize

    let fullPDFExportedPath: String

    init(design: Design, size: CGSize) {
        self.design = design
        self.workfolder = NSTemporaryDirectory()
        self.size = size
        fullPDFExportedPath = (workfolder as NSString).appendingPathComponent("\(prefix)-final-month.pdf")
        super.init()
        retainSelf = self
    }

    func export() -> URL {
        let paper = CGRect(origin: .zero, size: size)

        UIGraphicsBeginPDFContextToFile(fullPDFExportedPath, paper, nil)

        for page in 1..<13 {
            UIGraphicsBeginPDFPageWithInfo(paper, nil)
            if let context = UIGraphicsGetCurrentContext() {
                context.translateBy(x: 0, y: paper.size.height)
                context.scaleBy(x: 1.0, y: -1.0)

                let calendarView = CalendarView(design: design, frame: paper, fixedMonth: page)
                calendarView.layoutIfNeeded()
                context.draw(calendarView.snapshot!.cgImage!, in: paper)
                calendarView.cleanUp()
            }
        }

        UIGraphicsEndPDFContext()
        return URL(fileURLWithPath: fullPDFExportedPath)
    }

}
