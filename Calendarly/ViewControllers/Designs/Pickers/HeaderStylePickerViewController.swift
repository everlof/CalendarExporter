// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import UIKit

class HeaderStylePickerViewController: UITableViewController {

    static let reuseIdentifier = "HeaderStylePickerCell"

    var keyPath: ReferenceWritableKeyPath<Design, HeaderStyle>

    var object: Design

    init(object: Design, keyPath: ReferenceWritableKeyPath<Design, HeaderStyle>) {
        self.object = object
        self.keyPath = keyPath
        super.init(nibName: nil, bundle: nil)
        tableView.tableFooterView = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HeaderStyle.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: HeaderStylePickerViewController.reuseIdentifier)
        let headingStyle = HeaderStyle.all[indexPath.row]
        cell.textLabel?.text = headingStyle.description
        cell.accessoryType = object[keyPath: keyPath] == headingStyle ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)

            let prev = self.object[keyPath: self.keyPath]
            tableView.beginUpdates()
            if let prevIndex = HeaderStyle.all.index(of: prev) {
                tableView.reloadRows(at: [IndexPath(row: prevIndex, section: 0)], with: .fade)
            }
            self.object[keyPath: self.keyPath] = HeaderStyle.all[indexPath.row]
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

}
