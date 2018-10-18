import UIKit
import CoreData
import MBProgressHUD
import PickColor

class HTMLCalendarStylerNavigationController: UINavigationController {

    let viewController: HTMLCalendarStylerViewController

    init(design: Design, editingContext: NSManagedObjectContext, calendarView: CalendarView) {
        viewController = HTMLCalendarStylerViewController(design: design, editingContext: editingContext, calendarView: calendarView)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([viewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ColorPickerViewController: UIViewController, PickColorViewDelegate {

    lazy var pickerView: PickColorView = {
        return PickColorView(initialColor: UIColor(red: 1.0, green: 0.0, blue: 0.4, alpha: 1.0))
    }()

    let completed: ((UIColor) -> Void)

    init(completed: @escaping ((UIColor) -> Void)) {
        self.completed = completed
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pickerView)
        pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        pickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pickColorView(_: PickColorView, didManuallyEnterColor color: UIColor) {
        completed(color)
    }

    func pickColorView(_: PickColorView, didPickRecentColor color: UIColor) {
        completed(color)
    }

    func pickColorView(_: PickColorView, didTapSelectedColor color: UIColor) {
        completed(color)
    }

}

class HTMLCalendarStylerViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate {

    enum Section: Int {
        case general
        case title
        case weekdays
        case dates
    }

    enum GeneralRow: Int {
        case sampleMonth
        case primaryColor
        case secondaryColor
    }

    enum TitleRow: Int {
        case textualMonth
        case locale
        case monthFontsize
        case monthFont
    }

    enum WeekdayRow: Int {
        case headerFontsize
        case headerFont
    }

    enum DateRow: Int {
        case border
        case weekdayStyle
        case firstDayOfWeek
        case dateFontsize
        case dateFont
        case dateKerning
    }

    let tableView = UITableView(frame: .zero, style: .grouped)

    let design: Design

    let editingContext: NSManagedObjectContext

    let calendarView: CalendarView

    @objc func tap() {
        let textField = UITextField(frame: .zero)
        textField.text = design.name?.trimmingCharacters(in: .whitespaces)
        textField.sizeToFit()
        textField.textColor = UIColor.boneConstrastDarkest
        textField.returnKeyType = .done
        navigationItem.titleView = textField
        textField.delegate = self
        textField.becomeFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.sizeToFit()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
            design.name = textField.text
            UIView.setAnimationsEnabled(false)
            titleButtonItem.setTitle((design.name?.trimmingCharacters(in: .whitespaces)).map { "\($0), \(design.year)" }, for: .normal)
            UIView.setAnimationsEnabled(true)
        }
        navigationItem.titleView = titleButtonItem
        return false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    lazy var titleButtonItem: UIButton = {
        let titleButtonItem = UIButton(type: .custom)
        titleButtonItem.setTitle((design.name?.trimmingCharacters(in: .whitespaces)).map { "\($0), \(design.year)" }, for: .normal)
        titleButtonItem.setTitleColor(UIColor.boneConstrastDarkest, for: .normal)
        titleButtonItem.sizeToFit()
        titleButtonItem.addTarget(self, action: #selector(tap), for: .touchUpInside)
        return titleButtonItem
    }()

    init(design: Design, editingContext: NSManagedObjectContext, calendarView: CalendarView) {
        self.design = design
        self.editingContext = editingContext
        self.calendarView = calendarView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(didPressSave))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didPressExport))

        navigationItem.titleView = titleButtonItem
    }

    @objc func didPressExport() {
        if let designViewController = parent?.parent as? DesignViewController {
            designViewController.didPressExport()
        }
    }

    @objc func didPressSave() {
        if let designViewController = parent?.parent as? DesignViewController {
            designViewController.didPressSave()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        (localeCell.accessoryView as! UILabel).text = Locale.localizedDescription(for: design.locale.identifier)
        (localeCell.accessoryView as! UILabel).sizeToFit()

        (monthFontCell.accessoryView as! UILabel).text = design.monthFontname
        (monthFontCell.accessoryView as! UILabel).sizeToFit()

        (dateFontCell.accessoryView as! UILabel).text = design.dateFontname
        (dateFontCell.accessoryView as! UILabel).sizeToFit()

        (headerFontCell.accessoryView as! UILabel).text = design.headerFontname
        (headerFontCell.accessoryView as! UILabel).sizeToFit()
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch Section(rawValue: indexPath.section)! {
        case .general:
            return GeneralRow(rawValue: indexPath.row) != nil ? indexPath : nil
        case .title:
            return TitleRow(rawValue: indexPath.row) != nil ? indexPath : nil
        case .weekdays:
            return WeekdayRow(rawValue: indexPath.row) != nil ? indexPath : nil
        case .dates:
            return DateRow(rawValue: indexPath.row) != nil ? indexPath : nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let section = Section(rawValue: indexPath.section), section == .title,
            let row = TitleRow(rawValue: indexPath.row), row == .locale {
            let pickerController = LocalePickerViewController(design: design, keyPath: \Design.locale)
            navigationController?.pushViewController(pickerController, animated: true)
        }

        if let section = Section(rawValue: indexPath.section), section == .title,
            let row = TitleRow(rawValue: indexPath.row), row == .monthFont {
            let pickerController = FontPickerViewController(object: design,
                                                            keyPath: \Design.monthFont)
            navigationController?.pushViewController(pickerController, animated: true)
        }

        if let section = Section(rawValue: indexPath.section), section == .dates,
            let row = DateRow(rawValue: indexPath.row), row == .dateFont {
            let pickerController = FontPickerViewController(object: design,
                                                            keyPath: \Design.dateFont)
            navigationController?.pushViewController(pickerController, animated: true)
        }

        if let section = Section(rawValue: indexPath.section), section == .weekdays,
            let row = WeekdayRow(rawValue: indexPath.row), row == .headerFont {
            let pickerController = FontPickerViewController(object: design,
                                                            keyPath: \Design.headerFont)
            navigationController?.pushViewController(pickerController, animated: true)
        }

        if let section = Section(rawValue: indexPath.section), section == .general,
            let row = GeneralRow(rawValue: indexPath.row), row == .primaryColor {
            let colorPicker = ColorPickerViewController { color in
                if var colors = self.design.primaryColors as? [Int: UIColor] {
                    colors[Int(self.design.previewMonth)] = color
                    self.design.primaryColors = colors as NSObject
                } else {
                    self.design.primaryColors = [Int(self.design.previewMonth): color] as NSObject
                }
                self.updateColorCells()
            }
            navigationController?.pushViewController(colorPicker, animated: true)
        }

        if let section = Section(rawValue: indexPath.section), section == .general,
            let row = GeneralRow(rawValue: indexPath.row), row == .secondaryColor {
            let colorPicker = ColorPickerViewController { color in
                if var colors = self.design.secondaryColors as? [Int: UIColor] {
                    colors[Int(self.design.previewMonth)] = color
                    self.design.secondaryColors = colors as NSObject
                } else {
                    self.design.secondaryColors = [Int(self.design.previewMonth): color] as NSObject
                }
                self.updateColorCells()
            }
            navigationController?.pushViewController(colorPicker, animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .general:
            return (0..<Int.max).lazy.map({ GeneralRow(rawValue: $0) }).index(of: nil)!
        case .title:
            return (0..<Int.max).lazy.map({ TitleRow(rawValue: $0) }).index(of: nil)!
        case .weekdays:
            return (0..<Int.max).lazy.map({ WeekdayRow(rawValue: $0) }).index(of: nil)!
        case .dates:
            return (0..<Int.max).lazy.map({ DateRow(rawValue: $0) }).index(of: nil)!
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .general:
            return "General"
        case .title:
            return "Title"
        case .weekdays:
            return "Weekdays"
        case .dates:
            return "Dates"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .general:
            switch  GeneralRow(rawValue: indexPath.row)! {
            case .sampleMonth:
                return sampleMonthStepperCell
            case .primaryColor:
                return primaryColorCell
            case .secondaryColor:
                return secondaryColorCell
            }
        case .title:
            switch TitleRow(rawValue: indexPath.row)! {
            case .textualMonth:
                return textualMonthCell
            case .locale:
                return localeCell
            case .monthFontsize:
                return monthFontSizeCell

            case .monthFont:
                return monthFontCell
            }
        case .weekdays:
            switch WeekdayRow(rawValue: indexPath.row)! {
            case .headerFontsize:
                return headerFontSizeCell
            case .headerFont:
                return headerFontCell
            }
        case .dates:
            switch DateRow(rawValue: indexPath.row)! {
            case .border:
                return borderToggleCell
            case .weekdayStyle:
                return weekdayPrefixToggleCell
            case .firstDayOfWeek:
                return firstDayOfWeekToggleCell
            case .dateFontsize:
                return dayFontSizeCell
            case .dateFont:
                return dateFontCell
            case .dateKerning:
                return dateKerningCell
            }
        }
    }

    // MARK: Locale Cell

    lazy var localeCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Language"

        let label = UILabel()
        label.text = Locale.localizedDescription(for: design.locale.identifier)
        label.textColor = .secondaryTextColor
        label.sizeToFit()

        cell.accessoryView = label
        return cell
    }()

    // MARK: - Borders toggle cell

    lazy var borderToggleCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Borders"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = design.hasBorders
        borderSwitch.addTarget(self, action: #selector(toggleBorderSwitch), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func toggleBorderSwitch() {
        design.hasBorders = !design.hasBorders

        if design.hasBorders {
            (dayFontSizeCell.accessoryView as! UIStepper).value = Double(Design.dateFontSizeDefaultBordered)
            design.dateFontsize = Float(Design.dateFontSizeDefaultBordered)
        } else {
            (dayFontSizeCell.accessoryView as! UIStepper).value = Double(Design.dateFontSizeDefaultNonBordered)
            design.dateFontsize = Float(Design.dateFontSizeDefaultNonBordered)
        }
    }

    // MARK: - Textual month toggle cell

    lazy var textualMonthCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Numeric"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = design.numericMonthText
        borderSwitch.addTarget(self, action: #selector(textualMonthToggle), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func textualMonthToggle() {
        design.numericMonthText = !design.numericMonthText
    }

    // MARK: - Weekday prefix toggle cell

    lazy var weekdayPrefixToggleCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "1 letter weekday"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = true
        borderSwitch.addTarget(self, action: #selector(toggleWeekdaystyle), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func toggleWeekdaystyle() {
        // previewController.calendar.firstCharOfWeekday = !previewController.calendar.firstCharOfWeekday
    }

    // MARK: - First day of week cell

    lazy var firstDayOfWeekToggleCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Sunday"
        cell.detailTextLabel?.text = "Week start"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = design.firstDayOfWeek == .monday
        borderSwitch.addTarget(self, action: #selector(firstDayOfWeekToggle), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func firstDayOfWeekToggle() {
        if design.firstDayOfWeek == .monday {
            design.firstDayOfWeek = .sunday
        } else {
            design.firstDayOfWeek = .monday
        }
    }

    // MARK: - Sample month stepper cell

    lazy var sampleMonthStepperCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Month previewed"
        cell.selectionStyle = .none

        let stepper = UIStepper(frame: .zero)
        stepper.sizeToFit()
        stepper.minimumValue = 0
        stepper.value = Double(design.previewMonth)
        stepper.maximumValue = 11
        stepper.isContinuous = false
        stepper.addTarget(self, action: #selector(sampleMonthStepped), for: .valueChanged)

        stepper.setDecrementImage(UIImage(named: "ic_prev"), for: .normal)
        stepper.setIncrementImage(UIImage(named: "ic_next"), for: .normal)

        cell.accessoryView = stepper
        return cell
    }()

    @objc func sampleMonthStepped() {
        design.previewMonth = 1 + Int16((sampleMonthStepperCell.accessoryView as! UIStepper).value) % 12
        updateColorCells()
    }

    func updateColorCells() {
        primaryColorCell.accessoryView?.backgroundColor =
            (design.primaryColors as? [Int: UIColor])?[Int(design.previewMonth)] ?? UIColor.black
        secondaryColorCell.accessoryView?.backgroundColor =
            (design.secondaryColors as? [Int: UIColor])?[Int(design.previewMonth)] ?? UIColor.darkGray
    }

    // MARK: - Date font-size cell

    lazy var dayFontSizeCell: FontsizeCell = {
        return FontsizeCell(design: self.design, keyPath: \Design.dateFontsize, stepValue: 0.1, maximumFractionDigits: 1)
    }()

    // MARK: - Date kerning-size cell

    lazy var dateKerningCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Letter spacing"
        cell.selectionStyle = .none

        let stepper = UIStepper(frame: .zero)
        stepper.sizeToFit()
        stepper.value = Double(design.dateKerning)
        stepper.minimumValue = -100
        stepper.maximumValue = 100
        stepper.stepValue = 0.1
        stepper.isContinuous = false
        stepper.addTarget(self, action: #selector(kerningChanged), for: .valueChanged)

        cell.accessoryView = stepper
        return cell
    }()

    @objc func kerningChanged() {
        design.dateKerning = Float((dateKerningCell.accessoryView as! UIStepper).value)
        print(design.dateKerning)
    }

    // MARK: - Month font-size cell

    lazy var monthFontSizeCell: FontsizeCell = {
        return FontsizeCell(design: self.design, keyPath: \Design.monthFontsize, stepValue: 0.25, maximumFractionDigits: 2)
    }()

    @objc func monthFontSizeChanged() {
        design.monthFontsize = Float((monthFontSizeCell.accessoryView as! UIStepper).value)
    }

    // MARK: - Header font-size cell

    lazy var headerFontSizeCell: UITableViewCell = {
        return FontsizeCell(design: self.design, keyPath: \Design.headerFontsize, stepValue: 0.25, maximumFractionDigits: 2)
    }()

    @objc func headerFontSizeChanged() {
        design.headerFontsize = Float((headerFontSizeCell.accessoryView as! UIStepper).value)
    }

    // MARK: - Month font-size cell

    lazy var monthFontCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Font"

        let label = UILabel()
        label.text = design.monthFontname
        label.textColor = .secondaryTextColor
        label.sizeToFit()

        cell.accessoryView = label
        return cell
    }()

    // MARK: - Day font-size cell

    lazy var dateFontCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Font"

        let label = UILabel()
        label.text = design.dateFontname
        label.textColor = .secondaryTextColor
        label.sizeToFit()

        cell.accessoryView = label
        return cell
    }()

    // MARK: - Header font-size cell

    lazy var headerFontCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Font"

        let label = UILabel()
        label.text = design.headerFontname
        label.textColor = .secondaryTextColor
        label.sizeToFit()

        cell.accessoryView = label
        return cell
    }()

    lazy var primaryColorCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Primary color"
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1/UIScreen.main.scale
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = (design.primaryColors as? [Int: UIColor])?[Int(design.previewMonth)] ?? UIColor.black
        cell.accessoryView = view
        return cell
    }()

    lazy var secondaryColorCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Secondary color"
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1/UIScreen.main.scale
        view.backgroundColor = (design.secondaryColors as? [Int: UIColor])?[Int(design.previewMonth)] ?? UIColor.darkGray
        view.layer.borderColor = UIColor.lightGray.cgColor
        cell.accessoryView = view
        return cell
    }()

}
