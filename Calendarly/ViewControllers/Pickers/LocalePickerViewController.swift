import UIKit

class LocalePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView(frame: .zero, style: .grouped)

    var design: Design

    var keyPath: ReferenceWritableKeyPath<Design, Locale>

    let commonIdentifiers: [String] = {
        var preferred = Locale.preferredLanguages
        preferred.append(contentsOf: [
            "en",
            "fr",
            "zh-Hans",
            "zh-Hant"
        ])
        return Array(Set(preferred.sorted()))
    }()

    let identifiers: [String] = Locale.availableIdentifiers.sorted { s1, s2 in
        return
            (Locale.autoupdatingCurrent as NSLocale).displayName(forKey: .identifier, value: s1) ?? s1 <
            (Locale.autoupdatingCurrent as NSLocale).displayName(forKey: .identifier, value: s2) ?? s2
    }

    init(design: Design, keyPath: ReferenceWritableKeyPath<Design, Locale>) {
        self.design = design
        self.keyPath = keyPath
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
            _didSelect(locale: Locale(identifier: commonIdentifiers[indexPath.row]))
        default:
            _didSelect(locale: Locale(identifier: identifiers[indexPath.row]))
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? commonIdentifiers.count : identifiers.count
    }

    func updateCheckmark(cell: UITableViewCell, indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cell.accessoryType = commonIdentifiers[indexPath.row] == design[keyPath: keyPath].identifier ? .checkmark : .none
        default:
            cell.accessoryType = identifiers[indexPath.row] == design[keyPath: keyPath].identifier ? .checkmark : .none
        }
    }

    func _didSelect(locale: Locale) {
        design[keyPath: keyPath] = locale
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let value = indexPath.section == 0 ? commonIdentifiers[indexPath.row] : identifiers[indexPath.row]
        cell.textLabel?.text = Locale.localizedDescription(for: value)
        updateCheckmark(cell: cell, indexPath: indexPath)
        return cell
    }

}
