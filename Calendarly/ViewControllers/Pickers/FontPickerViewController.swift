import UIKit

protocol FontPickerViewControllerDelegate: class {
    func didSelect(font: UIFont)
}

class FontPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView(frame: .zero, style: .grouped)

    var currentFont: UIFont {
        didSet {
            if oldValue != currentFont {
                for section in 0..<tableView.numberOfSections {
                    for row in 0..<tableView.numberOfRows(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        if let cell = tableView.cellForRow(at: indexPath) {
                            updateCheckmark(cell: cell, indexPath: indexPath)
                        }
                    }
                }
            }
            print("Current => \(currentFont)")
        }
    }

    weak var delegate: FontPickerViewControllerDelegate?

    let fontNames: [String] = {
        return UIFont.familyNames.map { UIFont.fontNames(forFamilyName: $0) }.flatMap { $0 }.sorted()
    }()

    init(currentFont: UIFont) {
        self.currentFont = currentFont
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
        _didSelect(font: UIFont(name: fontNames[indexPath.row], size: 15)!)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontNames.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateCheckmark(cell: cell, indexPath: indexPath)
    }

    func updateCheckmark(cell: UITableViewCell, indexPath: IndexPath) {
        cell.accessoryType = fontNames[indexPath.row] == currentFont.fontName ? .checkmark : .none
    }

    func _didSelect(font: UIFont) {
        currentFont = font
        delegate?.didSelect(font: currentFont)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let value = fontNames[indexPath.row]
        cell.textLabel?.text = value
        cell.textLabel?.font = UIFont(name: value, size: 15)
        return cell
    }

}
