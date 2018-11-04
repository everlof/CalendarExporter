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


import CoreData
import UIKit

public class FRCCell<T>: UITableViewCell {

    static func identifier() -> String { return String(describing: self) }

    func configure(for: T) { fatalError("Implement in subclass") }

}

public class FetchedResultsControllerDelegate<Item, Cell: FRCCell<Item>>: NSObject,
    NSFetchedResultsControllerDelegate,
    UITableViewDelegate,
    UITableViewDataSource
    where Item: NSFetchRequestResult
{

    let controller: NSFetchedResultsController<Item>

    let tableView: UITableView

    var cellHeight: CGFloat?

    weak var delegate: UITableViewDelegate?

    var preConfigureCellClosure: ((Cell, IndexPath) -> Void)?

    init(controller: NSFetchedResultsController<Item>, tableView: UITableView, delegate: UITableViewDelegate?) {
        self.controller = controller
        self.tableView = tableView
        super.init()
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier())
        self.controller.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.delegate = delegate
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.sections.map {  $0[section].numberOfObjects } ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier(), for: indexPath) as! Cell
        let item: Item = controller.object(at: indexPath)
        preConfigureCellClosure?(cell, indexPath)
        print("Configuring cell at \(indexPath.row) with \(item)")
        cell.configure(for: item)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight ?? 44.0
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight ?? 44.0
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return controller.sections?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return delegate?.tableView?(tableView, willSelectRowAt: indexPath)
    }

    // MARK: NSFetchedResultsControllerDelegate

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func fetch() throws {
        try controller.performFetch()
        tableView.reloadData()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            newIndexPath.map { tableView.insertRows(at: [ $0 ], with: .automatic) }
        case .delete:
            indexPath.map { tableView.deleteRows(at: [ $0 ], with: .automatic) }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [ indexPath ], with: .none)
            } else if let newIndexPath = newIndexPath {
                tableView.reloadRows(at: [ newIndexPath ], with: .none)
            }
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
}
