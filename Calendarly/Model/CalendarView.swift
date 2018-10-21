import UIKit
import CoreData

class CalendarView: UIView,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

    /// The design being rendered in the calendar
    let design: Design

    /// The month
    private let titleLabel = UILabel()

    /// Container
    private let headingContainer = UIView(frame: .zero)

    /// Container
    private let contentContainer = UIView(frame: .zero)

    /// A fixed month has been set to render (instead of using the one in `design`
    let fixedMonth: Int?

    /// The border for each date item
    var borderWidth: CGFloat = 1

    lazy var titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = self.design.locale
        formatter.dateFormat = "MMMM"
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()

    var hasBorder: Bool = false {
        didSet {
            layer.borderWidth = hasBorder ? 1/UIScreen.main.scale : 0
            layer.borderColor = UIColor.boneConstrastDarkest.cgColor
        }
    }

    // MARK: - Various constraints

    var topConstraints: NSLayoutConstraint!

    var bottomConstraints: NSLayoutConstraint!

    var leftHeadingConstraints: NSLayoutConstraint!

    var leftContentConstraints: NSLayoutConstraint!

    var rightHeadingConstraints: NSLayoutConstraint!

    var rightContentConstraints: NSLayoutConstraint!

    var month: Int {
        return fixedMonth ?? Int(design.previewMonth)
    }

    var matrix = Calendar.current.dateMatrixFor(month: 1, year: 2017, config: .monday)

    var weekdayPrefixes = [String]()

    // MARK: - CollectionView

    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout()
    }()

    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "CalendarCollectionViewCell")
        return cv
    }()


    let isWatermarked: Bool

    let margins: UIEdgeInsets

    var size: CGSize = .zero {
        didSet {
            if oldValue != size {
                update()
            }
        }
    }

    /// Unit that is proportional to the height of the view's bounds
    var unit: CGFloat {
        return self.bounds.size.height / 100
    }

    var largerAggregatedMonthFont: UIFont {
        return UIFont(name: design.monthFontname!, size: 1.35 * unit * CGFloat(design.monthFontsize))!
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

    init(design: Design, isWatermarked: Bool = true, frame: CGRect = .zero, fixedMonth: Int? = nil) {
        self.design = design
        self.isWatermarked = isWatermarked
        self.fixedMonth = fixedMonth
        margins = UIEdgeInsets(top: 5, left: 3, bottom: 7, right: 3)
        super.init(frame: frame)

        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        headingContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

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

        contentContainer.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: contentContainer.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: contentContainer.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive = true

        if Environment.current.drawDebugColors {
            headingContainer.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            contentContainer.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        }

        topConstraints.constant = self.unit * margins.top
        bottomConstraints.constant = self.unit * -margins.bottom
        leftHeadingConstraints.constant = self.unit * margins.left
        leftContentConstraints.constant = self.unit * margins.left
        rightHeadingConstraints.constant = self.unit * -margins.right
        rightContentConstraints.constant = self.unit * -margins.right

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextChanged),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: design.managedObjectContext)

        update()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        size = bounds.size
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.width * sqrt(2))
    }

    @objc func contextChanged(notification: NSNotification) {
        guard let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>  else { return }
        if let _ = updates.first(where: { $0.objectID == self.design.objectID }) as? Design { self.update() }
    }

    func update() {
        matrix = Calendar.current.dateMatrixFor(month: month, year: Int(design.year), config: design.firstDayOfWeek)

        // GET ARRAY OF WEEKNAME
        weekdayPrefixes = Calendar.current.weekdayPrefixes(month: month, year: Int(design.year), locale: design.locale, config: design.firstDayOfWeek)

        // TAKE FIRST CHAR OF WEENKNAME
        weekdayPrefixes = weekdayPrefixes.map { String($0[0]) }

        topConstraints.constant = self.unit * self.margins.top
        bottomConstraints.constant = self.unit * -self.margins.bottom
        leftHeadingConstraints.constant = self.unit * self.margins.left
        leftContentConstraints.constant = self.unit * self.margins.left
        rightHeadingConstraints.constant = self.unit * -self.margins.right
        rightContentConstraints.constant = self.unit * -self.margins.right

        var comp = DateComponents()
        comp.year = Int(design.year)
        comp.month = month

        let secondaryColor = (design.secondaryColors as? [Int: UIColor])?[month] ?? UIColor.darkGray

        // SET CORRECT MONTH NUMBER OR NAME
        titleFormatter.locale = design.locale
        titleLabel.font = aggregatedMonthFont
        titleLabel.textColor = secondaryColor
        let titleText = design.numericMonthText ? "\(month)" : titleFormatter.string(from: Calendar.current.date(from: comp)!)

        switch design.headerStyle {
        case .regular:
            titleLabel.text = titleText
        case .firstLarger:
            let uppercased = titleText.uppercased(with: design.locale)
            guard let first = uppercased.first else { return }
            let attributedString = NSMutableAttributedString(string: String(first), attributes: [
                NSAttributedString.Key.font: largerAggregatedMonthFont,
                NSAttributedString.Key.foregroundColor: secondaryColor
                ])
            attributedString.append(
                NSAttributedString(string: String(uppercased.dropFirst()), attributes: [
                    NSAttributedString.Key.font: aggregatedMonthFont,
                    NSAttributedString.Key.foregroundColor: secondaryColor
                ]))
            titleLabel.attributedText = attributedString
        case .allCase:
            titleLabel.text = titleText.uppercased(with: design.locale)
        }

        if design.hasBorders {
            collectionView.backgroundColor = .lightGray
        } else {
            collectionView.backgroundColor = .white
        }

        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout  = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 1, height: 1) }

        guard design.hasBorders else {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            return CGSize(width: floor(collectionView.frame.width / 7),
                          height: floor(collectionView.frame.height / (CGFloat(collectionView.numberOfItems(inSection: 0)) / 7)))
        }

        flowLayout.minimumInteritemSpacing = borderWidth
        flowLayout.minimumLineSpacing = borderWidth

        flowLayout.sectionInset.bottom = borderWidth
        flowLayout.sectionInset.top = borderWidth
        flowLayout.sectionInset.right = borderWidth
        flowLayout.sectionInset.left = borderWidth

        let nbrInterItemSpaces: CGFloat = 7
        let totalInterItemSpace = flowLayout.minimumInteritemSpacing * nbrInterItemSpaces

        let nbrItems = CGFloat(collectionView.numberOfItems(inSection: 0))
        let nbrLineSpaces: CGFloat = (nbrItems / 7) - 1
        let totalLineSpace = flowLayout.minimumLineSpacing * nbrLineSpaces

        let availableWidth = (collectionView.frame.width - totalInterItemSpace - flowLayout.sectionInset.left - flowLayout.sectionInset.right)
        let widthPerItem = availableWidth / 7

        let availableHeight = (collectionView.frame.height - totalLineSpace - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom)
        let heightPerItem = availableHeight / (nbrItems / 7)

        return CGSize(width: widthPerItem, height: heightPerItem)
    }

    // MARK: - UICollectionViewDelegate

    

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 + matrix.count * matrix[0].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
        let modifiedIndexPath = indexPath.row - 7
        if indexPath.row < 7 {
            cell.set(date: weekdayPrefixes[indexPath.row], design: design, indexPath: indexPath, calendarView: self)
        } else if let i = matrix[modifiedIndexPath / 7][modifiedIndexPath % 7], i > 0 {
            cell.set(date: "\(i)", design: design, indexPath: indexPath, calendarView: self)
        } else {
            cell.set(date: "", design: design, indexPath: indexPath, calendarView: self)
        }
        return cell
    }

}


