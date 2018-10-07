import UIKit
import CoreData

class CalendarView: UIView {

    let design: Design

    let titleLabel = UILabel()

    let headingContainer = UIView(frame: .zero)

    let contentContainer = UIStackView(frame: .zero)

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.width * sqrt(2))
    }

    lazy var titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = self.design.locale
        formatter.dateFormat = "MMMM"
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()

    var timer: Timer!

    var hasBorder: Bool = false {
        didSet {
            layer.borderWidth = hasBorder ? 1/UIScreen.main.scale : 0
            layer.borderColor = UIColor.boneConstrastDarkest.cgColor
        }
    }

    var topConstraints: NSLayoutConstraint!
    var bottomConstraints: NSLayoutConstraint!
    var leftHeadingConstraints: NSLayoutConstraint!
    var leftContentConstraints: NSLayoutConstraint!
    var rightHeadingConstraints: NSLayoutConstraint!
    var rightContentConstraints: NSLayoutConstraint!

    init(design: Design, frame: CGRect = .zero) {
        self.design = design
        super.init(frame: frame)

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        headingContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        contentContainer.distribution = .fillEqually
        contentContainer.axis = .vertical

        addSubview(headingContainer)
        addSubview(contentContainer)

        headingContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true

        topConstraints = headingContainer.topAnchor.constraint(equalTo: topAnchor)
        topConstraints.isActive = true

        leftHeadingConstraints = headingContainer.leftAnchor.constraint(equalTo: leftAnchor)
        leftHeadingConstraints.isActive = true

        rightHeadingConstraints = headingContainer.rightAnchor.constraint(equalTo: rightAnchor)
        rightHeadingConstraints.isActive = true

        headingContainer.bottomAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true

        leftContentConstraints = contentContainer.leftAnchor.constraint(equalTo: leftAnchor)
        leftContentConstraints.isActive = true

        rightContentConstraints = contentContainer.rightAnchor.constraint(equalTo: rightAnchor)
        rightContentConstraints.isActive = true

        bottomConstraints = contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraints.isActive = true

        headingContainer.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: headingContainer.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: headingContainer.centerYAnchor).isActive = true

        if Environment.current.drawDebugColors {
            headingContainer.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            contentContainer.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        }

        layoutMargins = UIEdgeInsets(top: 5, left: 3, bottom: 7, right: 3)

        self.topConstraints.constant = self.unit * layoutMargins.top
        self.bottomConstraints.constant = self.unit * -layoutMargins.bottom
        self.leftHeadingConstraints.constant = self.unit * layoutMargins.left
        self.leftContentConstraints.constant = self.unit * layoutMargins.left
        self.rightHeadingConstraints.constant = self.unit * -layoutMargins.right
        self.rightContentConstraints.constant = self.unit * -layoutMargins.right

        update()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextChanged),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: design.managedObjectContext)

        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.titleLabel.font = self.aggregatedMonthFont
            self.titleLabel.sizeToFit()
            self.recursive(self.contentContainer, font: self.aggregatedHeaderFont, type: HeaderLabel.self)
            self.recursive(self.contentContainer, font: self.aggregatedDateFont, type: DateLabel.self)

            self.topConstraints.constant = self.unit * self.layoutMargins.top
            self.bottomConstraints.constant = self.unit * -self.layoutMargins.bottom
            self.leftHeadingConstraints.constant = self.unit * self.layoutMargins.left
            self.leftContentConstraints.constant = self.unit * self.layoutMargins.left
            self.rightHeadingConstraints.constant = self.unit * -self.layoutMargins.right
            self.rightContentConstraints.constant = self.unit * -self.layoutMargins.right
        }
    }

    func cleanUp() {
        timer.invalidate()
        timer = nil
    }

    var unit: CGFloat {
        return self.bounds.size.height / 100
    }

    var aggregatedMonthFont: UIFont {
        return UIFont(name: design.monthFontname!, size: unit * CGFloat(design.monthFontsize))!
    }

    var aggregatedDateFont: UIFont {
        return UIFont(name: design.dateFontname!, size: unit * CGFloat(design.dateFontsize))!
    }

    var aggregatedHeaderFont: UIFont {
        return UIFont(name: design.headerFontname!, size: unit * CGFloat(design.headerFontsize))!
    }

    @objc func contextChanged(notification: NSNotification) {
        guard let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>  else { return }

        print("Chaaaange!")

        if let design = updates.first(where: { $0.objectID == self.design.objectID }) as? Design {
            self.update()
        }
    }

    func firstCellView(_ view: UIView) -> UIView? {
        if view is CellView { return view }
        return view.subviews.compactMap { firstCellView($0) }.first
    }

    func recursive<T: UILabel>(_ view: UIView, font: UIFont, type: T.Type) {
        if let label = view as? T {
            label.font = font
            if type is DateLabel.Type {
                label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
                    NSAttributedString.Key.kern: self.unit * CGFloat(design.dateKerning)
                ])
            }
            label.sizeToFit()
        }
        view.subviews.forEach { recursive($0, font: font, type: type) }
    }

    class CellView: UIView {}
    class HeaderLabel: UILabel {}
    class DateLabel: UILabel {}

    func update() {
        var comp = DateComponents()
        comp.year = Int(design.year)
        comp.month = Int(design.previewMonth)

        // SET CORRECT MONTH NUMBER OR NAME
        titleLabel.font = aggregatedMonthFont
        titleLabel.text = design.numericMonthText ? "\(design.previewMonth)" : titleFormatter.string(from: Calendar.current.date(from: comp)!)

        // CLEAR PREVIOUS CELLS
        contentContainer.subviews.forEach { $0.removeFromSuperview() }

        // GET ARRAY OF WEEKNAME
        var weekdayPrefixes = Calendar.current.weekdayPrefixes(month: Int(design.previewMonth), year: Int(design.year), locale: design.locale, config: design.firstDayOfWeek)

        // TAKE FIRST CHAR OF WEENKNAME
        weekdayPrefixes = weekdayPrefixes.map { String($0[0]) }

        // INSERT FIRST ROW, CONTAINING OF WEEKNAMES
        let rowView = UIStackView(frame: .zero)
        rowView.axis = .horizontal
        rowView.distribution = .fillEqually
        for headerCharacter in weekdayPrefixes {
            let cellView = CellView(frame: .zero)
            let dateLabel = HeaderLabel(frame: .zero)
            dateLabel.font = aggregatedHeaderFont

            if Environment.current.drawDebugColors {
                dateLabel.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            }

            cellView.addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
            dateLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
            dateLabel.text = headerCharacter
            rowView.addArrangedSubview(cellView)
        }
        contentContainer.addArrangedSubview(rowView)

        let nbrFormatter: NumberFormatter = NumberFormatter()
        nbrFormatter.locale = design.locale

        // INSERT REST OF ROWS, FOR DATES
        for row in Calendar.current.dateMatrixFor(month: Int(design.previewMonth), year: Int(design.year), config: design.firstDayOfWeek) {
            let rowView = UIStackView(frame: .zero)
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually

            for col in row {
                let cellView = CellView(frame: .zero)
                cellView.backgroundColor = .clear

                let dateLabel = DateLabel(frame: .zero)
                dateLabel.font = aggregatedDateFont

                if Environment.current.drawDebugColors {
                    dateLabel.backgroundColor = UIColor.green.withAlphaComponent(0.5)
                } else {
                    dateLabel.backgroundColor = .clear
                }

                cellView.addSubview(dateLabel)
                dateLabel.translatesAutoresizingMaskIntoConstraints = false
                dateLabel.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
                dateLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true

                if let col = col, col != 0 {
                    let text = nbrFormatter.string(from: NSNumber(integerLiteral: col))!
                    dateLabel.attributedText = NSAttributedString(string: text, attributes: [
                        NSAttributedString.Key.kern: self.unit * CGFloat(design.dateKerning)
                    ])
                }

                rowView.addArrangedSubview(cellView)
            }
            contentContainer.addArrangedSubview(rowView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
