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

    init(design: Design, frame: CGRect = .zero) {
        self.design = design
        super.init(frame: frame)

        layer.borderWidth = 1
        layer.borderColor = UIColor.boneConstrastDarkest.cgColor

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        headingContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        contentContainer.distribution = .fillEqually
        contentContainer.axis = .vertical

        addSubview(headingContainer)
        addSubview(contentContainer)

        headingContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0/3.0).isActive = true
        headingContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headingContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        headingContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        headingContainer.bottomAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true

        contentContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        headingContainer.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: headingContainer.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: headingContainer.centerYAnchor).isActive = true

        update()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextChanged),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: design.managedObjectContext)

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.titleLabel.font = self.aggregatedMonthFont
            self.recursive(self.contentContainer, font: self.aggregatedHeaderFont, type: HeaderLabel.self)
            self.recursive(self.contentContainer, font: self.aggregatedDateFont, type: DateLabel.self)
        }
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
                let dateLabel = DateLabel(frame: .zero)
                dateLabel.font = aggregatedDateFont

                cellView.addSubview(dateLabel)
                dateLabel.translatesAutoresizingMaskIntoConstraints = false
                dateLabel.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
                dateLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true

                if let col = col, col != 0 {
                    dateLabel.text = nbrFormatter.string(from: NSNumber(integerLiteral: col))!
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
