import Foundation
import UIKit
import CoreData

protocol HTMLCalendarDelegate: class {
    func contentDidChange()
}

struct ColorCombo {
    let primaryColor: UIColor
    let secondayColor: UIColor

    static let black: ColorCombo = {
        return ColorCombo(primaryColor: .black, secondayColor: .darkGray)
    }()

    static let red: ColorCombo = {
        return ColorCombo(primaryColor: .red, secondayColor: UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0))
    }()

}

class HTMLCalendar {

    weak var delegate: HTMLCalendarDelegate?

    let design: Design

    init(design: Design) {
        self.design = design
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextChanged),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: design.managedObjectContext)
    }

    @objc func contextChanged(notification: NSNotification) {
        guard let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>  else { return }

        if let design = updates.first(where: { $0.objectID == self.design.objectID }) as? Design {
            delegate?.contentDidChange()
            try? design.managedObjectContext?.save()
            try? design.managedObjectContext?.parent?.save()
        }
    }

    private func element(month: Int16, year: Int16) -> Element {
        let formatter = DateFormatter()
        formatter.locale = design.locale
        formatter.dateFormat = "MMMM"
        formatter.formattingContext = .beginningOfSentence

        var comp = DateComponents()
        comp.year = Int(year)
        comp.month = Int(month)

        let headerContent = design.numericMonthText ? "\(month)" : formatter.string(from: Calendar.current.date(from: comp)!)

        let monthElement = Element(tag: .div, attr: ["class": "month"], children: [
            Element(tag: .div, attr: ["class": "header"], children: [
                Element(tag: .div, content: .text(headerContent), attr: ["align": "center"])])
            ])

        let tr: Element = .tr
        let table = Element(tag: .table, children: [tr])
        let content = Element(tag: .div, attr: ["class": "content"], children: [table])

        var weekdayPrefixes = Calendar.current.weekdayPrefixes(month: Int(month), year: Int(year), locale: design.locale, config: design.firstDayOfWeek)

        if true {
            weekdayPrefixes = weekdayPrefixes.map { String($0[0]) }
        }

        for headerCharacter in weekdayPrefixes {
            tr.append(Element(tag: .th, content: .text(headerCharacter)))
        }

        let nbrFormatter: NumberFormatter = NumberFormatter()
        nbrFormatter.locale = design.locale

        for row in Calendar.current.dateMatrixFor(month: Int(month), year: Int(year), config: design.firstDayOfWeek) {
            let tr: Element = .tr
            for col in row {
                if let col = col, col != 0 {
                    tr.append(Element(tag: .td, content: .text(nbrFormatter.string(from: NSNumber(integerLiteral: col))!)))
                } else {
                    tr.append(Element(tag: .td, content: .text("")))
                }
            }
            table.append(tr)
        }

        return monthElement.append(content)
    }

    func export(month: Int? = nil, forPDF: Bool = false) -> String {
        let monthToExport = month ?? Int(design.previewMonth)

        var cssRules = [
            CSSRule(selectors: ["html"], rules: [
                "font-size": forPDF ? "1000%" : "100%",
                "font-family": design.monthFontname!, // "ArialRoundedMTBold", // Configurable
                "padding": "0rem",
                "margin": "0rem",
            ]),
            CSSRule(selectors: ["body"], rules: [
                "margin": "1em", // Configurable
                "padding": "0rem",
            ]),
            CSSRule(selectors: ["div.header > div"], rules: [
                "font-family": design.monthFontname!,
                "font-size": "\(CGFloat(design.monthFontsize))rem",
                "color": design.colors[monthToExport].primaryColor.toHex(), // "#74cc82",
                "position": "relative",
                "transform": "translateY(-50%)",
                "-webkit-transform": "translateY(-50%)",
                "top": "50%"
            ]),
            CSSRule(selectors: [".header"], rules: [
                "height": "30%",
                "width": "100%",
            ]),
            CSSRule(selectors: [".content"], rules: [
                "height": "70%",
                "width": "100%",
            ]),
            CSSRule(selectors: ["table"], rules: [
                "border-collapse": "collapse",
                "table-layout": "fixed",
                "height": "100%",
                "width": "100%",
            ]),
            CSSRule(selectors: ["td"], rules: [
                "letter-spacing": "-0.15rem",
                "text-align": "center",
            ]),
            CSSRule(selectors: ["th", "td"], rules: [
                "font-family": design.dateFontname!,
                "color": design.colors[monthToExport].secondayColor.toHex() // "#1a4567"
            ]),
        ]

        let root: Element = .html

        if design.hasBorders {
            cssRules.append(CSSRule(selectors: ["td"], rules: [
                "position": "relative",
                "top": "-10px",
                "font-size": "\(design.dateFontsize)rem",
                "border": "1px solid #ccc",
            ]))
        } else {
            cssRules.append(CSSRule(selectors: ["td"], rules: [
                "font-size": "\(design.dateFontsize)rem"
            ]))
        }

        switch design.firstDayOfWeek {
        case .monday:
            cssRules.append(CSSRule(selectors: ["td:last-child", "th:last-child"], rules: [
                "color": design.colors[monthToExport].primaryColor.toHex() // "#74cc82"
            ]))
        case .sunday:
            cssRules.append(CSSRule(selectors: ["td:first-child", "th:first-child"], rules: [
                "color": design.colors[monthToExport].primaryColor.toHex() // "#74cc82"
            ]))
        }

        if true {
            cssRules.append(CSSRule(selectors: ["th"], rules: [
                "font-size": "0.5rem"
            ]))
        } else {
            cssRules.append(CSSRule(selectors: ["th"], rules: [
                "font-size": "0.01rem",
                "letter-spacing": "-0.1rem"
            ]))
        }

        root.append(
            .head,
            .body
        )

        root.children[0].append(
            Element(tag: .meta, attr: ["charset": "UTF-8"]),
            .style(cssRules)
        )

        root.children[1].append(element(month: Int16(monthToExport), year: design.year))

        return root.export(prettyPrint: true)
    }

}
