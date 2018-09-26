import Foundation
import UIKit

protocol HTMLCalendarDelegate: class {
    func contentDidChange()
}

enum FirstDayOfWeek {
    case sunday
    case monday
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

    static let dateFontSizeDefaultBordered: CGFloat = 1.5

    static let dateFontSizeDefaultNonBordered: CGFloat = 1.9

    static let monthFontSizeDefault: CGFloat = 3.0

    // MARK: Config variables

    var locale: Locale { didSet { delegate?.contentDidChange() } }

    var year: Int { didSet { delegate?.contentDidChange() } }

    var hasBorders: Bool = false { didSet { delegate?.contentDidChange() } }

    var firstCharOfWeekday: Bool = true { didSet { delegate?.contentDidChange() } }

    var textualMonth: Bool = true { didSet { delegate?.contentDidChange() } }

    var firstDayOfWeek: FirstDayOfWeek = .monday { didSet { delegate?.contentDidChange() } }

    var dayFontSize: Double = Double(HTMLCalendar.dateFontSizeDefaultNonBordered) { didSet { delegate?.contentDidChange() } }

    var monthFontSize: Double = Double(HTMLCalendar.monthFontSizeDefault) { didSet { delegate?.contentDidChange() } }

    var month: Int = 1 { didSet { delegate?.contentDidChange() } }

    var font: UIFont = UIFont(name: "ArialRoundedMTBold", size: 12)! { didSet { delegate?.contentDidChange() } }

    var colors: [ColorCombo] = {
        return (0..<12).map { i in return i % 2 == 0 ? ColorCombo.red : ColorCombo.black }
    }()

    init(year: Int, locale: Locale) {
        self.year = year
        self.locale = locale
    }

    private func element(month: Int, year: Int) -> Element {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMMM"
        formatter.formattingContext = .beginningOfSentence

        var comp = DateComponents()
        comp.year = year
        comp.month = month

        let headerContent = textualMonth ? formatter.string(from: Calendar.current.date(from: comp)!) : "\(month)"

        let monthElement = Element(tag: .div, attr: ["class": "month"], children: [
            Element(tag: .div, attr: ["class": "header"], children: [
                Element(tag: .div,
                        content: .text(headerContent),
                        attr: ["align": "center"])
                ])
            ])

        let tr: Element = .tr
        let table = Element(tag: .table, children: [tr])
        let content = Element(tag: .div, attr: ["class": "content"], children: [table])

        var weekdayPrefixes = Calendar.current.weekdayPrefixes(month: month, year: year, locale: locale, config: firstDayOfWeek)

        if firstCharOfWeekday {
            weekdayPrefixes = weekdayPrefixes.map { String($0[0]) }
        }

        for headerCharacter in weekdayPrefixes {
            tr.append(Element(tag: .th, content: .text(headerCharacter)))
        }

        let nbrFormatter: NumberFormatter = NumberFormatter()
        nbrFormatter.locale = locale

        for row in Calendar.current.dateMatrixFor(month: month, year: year, config: firstDayOfWeek) {
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

    func export() -> String {
        var cssRules = [
            CSSRule(selectors: ["html"], rules: [
                "font-size": "100%", // Configurable
                "font-family": font.fontName, // "ArialRoundedMTBold", // Configurable
                "padding": "0rem",
                "margin": "0rem",
            ]),
            CSSRule(selectors: ["body"], rules: [
                "margin": "1em", // Configurable
                "padding": "0rem",
            ]),
            CSSRule(selectors: ["div.header > div"], rules: [
                "font-size": "\(monthFontSize)rem",
                "color": colors[month].primaryColor.toHex(), // "#74cc82",
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
                "color": colors[month].secondayColor.toHex() // "#1a4567"
            ]),
        ]

        let root: Element = .html

        if hasBorders {
            cssRules.append(CSSRule(selectors: ["td"], rules: [
                "position": "relative",
                "top": "-10px",
                "font-size": "\(dayFontSize)rem",
                "border": "1px solid #ccc",
            ]))
        } else {
            cssRules.append(CSSRule(selectors: ["td"], rules: [
                "font-size": "\(dayFontSize)rem"
            ]))
        }

        switch firstDayOfWeek {
        case .monday:
            cssRules.append(CSSRule(selectors: ["td:last-child", "th:last-child"], rules: [
                "color": colors[month].primaryColor.toHex() // "#74cc82"
            ]))
        case .sunday:
            cssRules.append(CSSRule(selectors: ["td:first-child", "th:first-child"], rules: [
                "color": colors[month].primaryColor.toHex() // "#74cc82"
            ]))
        }

        if firstCharOfWeekday {
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

        root.children[1].append(element(month: month, year: year))

        return root.export(prettyPrint: true)
    }

}
