import UIKit

protocol LocalePickerViewControllerDelegate: class {
    func didSelect(locale: Locale)
}

class LocalePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView(frame: .zero, style: .grouped)

    var currentLocale: Locale {
        didSet {
            if oldValue != currentLocale {
                for section in 0..<tableView.numberOfSections {
                    for row in 0..<tableView.numberOfRows(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        if let cell = tableView.cellForRow(at: indexPath) {
                            updateCheckmark(cell: cell, indexPath: indexPath)
                        }
                    }
                }
            }
            print("Current => \(currentLocale.identifier)")
        }
    }

    weak var delegate: LocalePickerViewControllerDelegate?

    let preferredIdentifiers = [
        "en",
        "fr",
        "zh_Hans",
        "zh_Hant"
    ]

    let identifiers: [String] = Locale.availableIdentifiers.sorted { s1, s2 in
        return
            (Locale.autoupdatingCurrent as NSLocale).displayName(forKey: .identifier, value: s1)! <
            (Locale.autoupdatingCurrent as NSLocale).displayName(forKey: .identifier, value: s2)!
    }

    init(currentLocale: Locale) {
        self.currentLocale = currentLocale
        print(currentLocale.identifier)
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
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            _didSelect(locale: Locale(identifier: preferredIdentifiers[indexPath.row]))
        default:
            _didSelect(locale: Locale(identifier: identifiers[indexPath.row]))
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? preferredIdentifiers.count : identifiers.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateCheckmark(cell: cell, indexPath: indexPath)
    }

    func updateCheckmark(cell: UITableViewCell, indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cell.accessoryType = preferredIdentifiers[indexPath.row] == currentLocale.identifier ? .checkmark : .none
        default:
            cell.accessoryType = identifiers[indexPath.row] == currentLocale.identifier ? .checkmark : .none
        }
    }

    func _didSelect(locale: Locale) {
        currentLocale = locale
        delegate?.didSelect(locale: locale)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let value = indexPath.section == 0 ? preferredIdentifiers[indexPath.row] : identifiers[indexPath.row]
        cell.textLabel?.text = Locale.localizedDescription(for: value)
        return cell
    }

}
