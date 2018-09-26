import UIKit

class HTMLCalendarStylerNavigationController: UINavigationController {

    let styleViewController: HTMLCalendarStylerViewController

    init(previewController: HTMLCalendarPreviewController) {
        self.styleViewController = HTMLCalendarStylerViewController(previewController: previewController)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([styleViewController], animated: true)
    }

}

class HTMLCalendarStylerViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    LocalePickerViewControllerDelegate,
    FontPickerViewControllerDelegate {

    enum Section: Int {
        case title
        case body
    }

    enum TitleRow: Int {
        case textualMonth
        case locale
        case sampleMonth
        case monthFontSize
        case font
    }

    enum BodyRow: Int {
        case border
        case weekdayStyle
        case firstDayOfWeek
        case dayFontSize
    }

    let previewController: HTMLCalendarPreviewController

    let tableView = UITableView(frame: .zero, style: .grouped)

    init(previewController: HTMLCalendarPreviewController) {
        self.previewController = previewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Inställningar"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        (localeCell.accessoryView as! UILabel).text = Locale.localizedDescription(for: previewController.calendar.locale.identifier)
        (localeCell.accessoryView as! UILabel).sizeToFit()

        (fontCell.accessoryView as! UILabel).text = previewController.calendar.font.fontName
        (fontCell.accessoryView as! UILabel).sizeToFit()
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch Section(rawValue: indexPath.section)! {
        case .title:
            return TitleRow(rawValue: indexPath.row) != nil ? indexPath : nil
        case .body:
            return BodyRow(rawValue: indexPath.row) != nil ? indexPath : nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let section = Section(rawValue: indexPath.section), section == .title,
            let row = TitleRow(rawValue: indexPath.row), row == .locale {
            let pickerController = LocalePickerViewController(currentLocale: previewController.calendar.locale)
            pickerController.delegate = self
            navigationController?.pushViewController(pickerController, animated: true)
        }

        if let section = Section(rawValue: indexPath.section), section == .title,
            let row = TitleRow(rawValue: indexPath.row), row == .font {
            let pickerController = FontPickerViewController(currentFont: previewController.calendar.font)
            pickerController.delegate = self
            navigationController?.pushViewController(pickerController, animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .title:
            return (0..<Int.max).lazy.map({ TitleRow(rawValue: $0) }).index(of: nil)!
        case .body:
            return (0..<Int.max).lazy.map({ BodyRow(rawValue: $0) }).index(of: nil)!
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .title:
            return "Heading"
        case .body:
            return "Body"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .title:
            switch TitleRow(rawValue: indexPath.row)! {
            case .textualMonth:
                return textualMonthCell
            case .locale:
                return localeCell
            case .monthFontSize:
                return monthFontSizeCell
            case .sampleMonth:
                return sampleMonthStepperCell
            case .font:
                return fontCell
            }
        case .body:
            switch BodyRow(rawValue: indexPath.row)! {
            case .border:
                return borderToggleCell
            case .weekdayStyle:
                return weekdayPrefixToggleCell
            case .firstDayOfWeek:
                return firstDayOfWeekToggleCell
            case .dayFontSize:
                return dayFontSizeCell
            }
        }
    }

    // MARK: - LocalePickerViewControllerDelegate

    func didSelect(locale: Locale) {
        previewController.calendar.locale = locale
    }

    // MARK: Locale Cell

    lazy var localeCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Language"

        let label = UILabel()
        label.text = Locale.localizedDescription(for: previewController.calendar.locale.identifier)
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
        borderSwitch.isOn = previewController.calendar.hasBorders
        borderSwitch.addTarget(self, action: #selector(toggleBorderSwitch), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func toggleBorderSwitch() {
        previewController.calendar.hasBorders = !previewController.calendar.hasBorders

        if previewController.calendar.hasBorders {
            (dayFontSizeCell.accessoryView as! UIStepper).value = 1.6
            previewController.calendar.dayFontSize = 1.6
        } else {
            (dayFontSizeCell.accessoryView as! UIStepper).value = 2.0
            previewController.calendar.dayFontSize = 2.0
        }
    }

    // MARK: - Textual month toggle cell

    lazy var textualMonthCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Textual month"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = previewController.calendar.textualMonth
        borderSwitch.addTarget(self, action: #selector(textualMonthToggle), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func textualMonthToggle() {
        previewController.calendar.textualMonth = !previewController.calendar.textualMonth
    }

    // MARK: - Weekday prefix toggle cell

    lazy var weekdayPrefixToggleCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Short weekday-name"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = previewController.calendar.firstCharOfWeekday
        borderSwitch.addTarget(self, action: #selector(toggleWeekdaystyle), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func toggleWeekdaystyle() {
        previewController.calendar.firstCharOfWeekday = !previewController.calendar.firstCharOfWeekday
    }

    // MARK: - First day of week cell

    lazy var firstDayOfWeekToggleCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Week start: Sunday"
        cell.selectionStyle = .none

        let borderSwitch = UISwitch(frame: .zero)
        borderSwitch.isOn = previewController.calendar.firstDayOfWeek == .monday
        borderSwitch.addTarget(self, action: #selector(firstDayOfWeekToggle), for: .valueChanged)

        cell.accessoryView = borderSwitch
        return cell
    }()

    @objc func firstDayOfWeekToggle() {
        if previewController.calendar.firstDayOfWeek == .monday {
            previewController.calendar.firstDayOfWeek = .sunday
        } else {
            previewController.calendar.firstDayOfWeek = .monday
        }
    }

    // MARK: - Sample month stepper cell

    lazy var sampleMonthStepperCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Preview month"
        cell.selectionStyle = .none

        let stepper = UIStepper(frame: .zero)
        stepper.sizeToFit()
        stepper.minimumValue = 0
        stepper.maximumValue = 11
        stepper.isContinuous = false
        stepper.addTarget(self, action: #selector(sampleMonthStepped), for: .valueChanged)

        cell.accessoryView = stepper
        return cell
    }()

    @objc func sampleMonthStepped() {
        previewController.calendar.month = 1 + Int((sampleMonthStepperCell.accessoryView as! UIStepper).value) % 12
    }

    // MARK: - Date font-size cell

    lazy var dayFontSizeCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Day font-size"
        cell.selectionStyle = .none

        let stepper = UIStepper(frame: .zero)
        stepper.sizeToFit()
        stepper.value = previewController.calendar.dayFontSize
        stepper.minimumValue = 0
        stepper.maximumValue = 14
        stepper.stepValue = 0.1
        stepper.isContinuous = false
        stepper.addTarget(self, action: #selector(dayFontSizeChanged), for: .valueChanged)

        cell.accessoryView = stepper
        return cell
    }()

    @objc func dayFontSizeChanged() {
        previewController.calendar.dayFontSize = (dayFontSizeCell.accessoryView as! UIStepper).value
    }

    // MARK: - Month font-size cell

    lazy var monthFontSizeCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Month font-size"
        cell.selectionStyle = .none

        let stepper = UIStepper(frame: .zero)
        stepper.sizeToFit()
        stepper.value = previewController.calendar.monthFontSize
        stepper.minimumValue = 2
        stepper.maximumValue = 8
        stepper.stepValue = 0.1
        stepper.isContinuous = false
        stepper.addTarget(self, action: #selector(monthFontSizeChanged), for: .valueChanged)

        cell.accessoryView = stepper
        return cell
    }()

    @objc func monthFontSizeChanged() {
        previewController.calendar.monthFontSize = (monthFontSizeCell.accessoryView as! UIStepper).value
    }

    // MARK: - Month font-size cell

    lazy var fontCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.textLabel?.text = "Font"

        let label = UILabel()
        label.text = previewController.calendar.font.fontName
        label.textColor = .secondaryTextColor
        label.sizeToFit()

        cell.accessoryView = label
        return cell
    }()

    func didSelect(font: UIFont) {
        previewController.calendar.font = font
    }

}
