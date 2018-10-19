import UIKit
import MBProgressHUD
import Foundation
import CoreData

enum FirstDayOfWeek {
    case sunday
    case monday
}

enum HeaderStyle: String {
    case regular
    case firstLarger
    case allCase

    static var all: [HeaderStyle] = [.regular, .firstLarger, .allCase]
}

extension HeaderStyle: Equatable {

    public static func == (lhs: HeaderStyle, rhs: HeaderStyle) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

}

extension HeaderStyle: CustomStringConvertible {

    var description: String {
        switch self {
        case .regular:
            return "Regular"
        case .allCase:
            return "All case"
        case .firstLarger:
            return "First larger"
        }
    }

}

extension Design {

    static let dateFontSizeDefaultBordered: CGFloat = 5.4

    static let dateFontSizeDefaultNonBordered: CGFloat = 5.4

    static let headerFontSizeDefault: CGFloat = 1.9

    static let monthFontSizeDefault: CGFloat = 8.0

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

        design.dateKerning = -0.3

        design.previewMonth = 1
        design.snapshotFilename = String(format: "%@.png", UUID().uuidString)
        design.headerStyle = .regular

        return design
    }

    func primaryColor(for month: Int) -> UIColor {
        return (primaryColors as? [Int: UIColor])?[month] ?? UIColor.black
    }
    func secondaryColor(for month: Int) -> UIColor{
        return (secondaryColors as? [Int: UIColor])?[month] ?? UIColor.darkGray
    }

    var headerStyle: HeaderStyle {
        get {
            guard let string = headerStyleString else { return .regular }
            return HeaderStyle(rawValue: string) ?? .regular
        }
        set {
            headerStyleString = newValue.rawValue
        }
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
        // view.cleanUp()
    }

}

class CalendarBook: NSObject, UIWebViewDelegate {

    let design: Design

    let workfolder: String

    var done: ((URL) -> Void)!

    var retainSelf: CalendarBook!

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

    static func createProgress() -> Progress {
        return Progress(totalUnitCount: 12)
    }

    func export(completed: @escaping ((URL) -> Void)) {
        let paper = CGRect(origin: .zero, size: size)

        UIGraphicsBeginPDFContextToFile(fullPDFExportedPath, paper, nil)

        var operations = [Operation]()

        for page in 1..<13 {
            let block = BlockOperation {
                UIGraphicsBeginPDFPageWithInfo(paper, nil)
                print("Performing page: \(page)")
                if let context = UIGraphicsGetCurrentContext() {
                    context.translateBy(x: 0, y: paper.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)

                    let calendarView = CalendarView(design: self.design, frame: paper, fixedMonth: page)
                    calendarView.layoutIfNeeded()
                    context.draw(calendarView.snapshot!.cgImage!, in: paper)
//                    calendarView.cleanUp()
                }
            }

            operations.last.map { block.addDependency($0) }
            operations.append(block)
        }

        let lastBlock = BlockOperation(block: {
            UIGraphicsEndPDFContext()
            completed(URL(fileURLWithPath: self.fullPDFExportedPath))
            self.retainSelf = nil
        })

        operations.last.map { lastBlock.addDependency($0) }
        operations.append(lastBlock)
        operations.forEach { op in DispatchQueue.main.async { op.start() } }
    }

}
