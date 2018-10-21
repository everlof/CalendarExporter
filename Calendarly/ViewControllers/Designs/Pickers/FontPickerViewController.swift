import UIKit

class FontPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView(frame: .zero, style: .grouped)

    var currFont: ReferenceWritableKeyPath<Design, UIFont>

    var object: Design

    static let fontNames: [String] = {
        return UIFont.familyNames.map { UIFont.fontNames(forFamilyName: $0) }.flatMap { $0 }.sorted()
    }()

    init(object: Design, keyPath: ReferenceWritableKeyPath<Design, UIFont>) {
        self.object = object
        self.currFont = keyPath
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
        _didSelect(font: UIFont(name: FontPickerViewController.fontNames[indexPath.row], size: 15)!)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FontPickerViewController.fontNames.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateCheckmark(cell: cell, indexPath: indexPath)
    }

    func updateCheckmark(cell: UITableViewCell, indexPath: IndexPath) {
        cell.accessoryType = FontPickerViewController.fontNames[indexPath.row] == self.object[keyPath: self.currFont].fontName ?
            .checkmark :
            .none
    }

    func _didSelect(font: UIFont) {
        self.object[keyPath: self.currFont] = font
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let value = FontPickerViewController.fontNames[indexPath.row]
        cell.textLabel?.text = value
        cell.textLabel?.font = UIFont(name: value, size: 15)
        return cell
    }

}
