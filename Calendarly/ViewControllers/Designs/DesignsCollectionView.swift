import UIKit
import CoreData

extension NSNotification.Name {

    static let exportSelectedDesign = NSNotification.Name(rawValue: "exportSelectedDesign")

}

class CalendarDesignCollectionViewCell: UICollectionViewCell {

    let imageView = A4SizingImageView()

    private var boundsObserver: NSKeyValueObservation!

    private var widthConstraint: NSLayoutConstraint!

    class A4SizingImageView: UIImageView {

        override var intrinsicContentSize: CGSize {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }

    }

    override init(frame: CGRect) {
        imageView.contentMode = .scaleAspectFit

//        imageView.layer.borderColor = UIColor.darkGray.cgColor
//        imageView.layer.borderWidth = 1/UIScreen.main.scale
        imageView.layer.masksToBounds = true

        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9).isActive = true

        imageView.backgroundColor = .clear

        widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive = true

        boundsObserver = self.observe(\.bounds) { (observing, value) in
            self.widthConstraint.constant = self.bounds.height / sqrt(2)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with design: Design) {
        design.snapshot { img in self.imageView.image = img }
    }

}

protocol DesignsCollectionViewDelegate: class {
    func present(design: Design)
}

class DesignsCollectionView: UICollectionView,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    NSFetchedResultsControllerDelegate {

    let layout = UICollectionViewFlowLayout()

    private var boundsObserver: NSKeyValueObservation!

    var columns: Int = 2

    var sectionInsets: UIEdgeInsets = .zero {
        didSet {
            layout.sectionInset = sectionInsets
            needUpdateSizes()
        }
    }

    weak var designsDelegate: DesignsCollectionViewDelegate?

    lazy var fetchedResultController: NSFetchedResultsController<Design> = {
        let fr = NSFetchRequest<Design>(entityName: Design.self.description())
        fr.sortDescriptors = [NSSortDescriptor(keyPath: \Design.created, ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: self.persistentContainer.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc

    }()

    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = UIColor.boneWhiteColor
        delegate = self
        dataSource = self
        register(CalendarDesignCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        try! fetchedResultController.performFetch()
        reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func needUpdateSizes() {
        let portrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        columns = portrait ? 2 : 3
        let interimSpacing = (CGFloat(columns) - 1) * layout.minimumInteritemSpacing
        let side =
            floor((bounds.width
                - interimSpacing
                - layout.sectionInset.left
                - layout.sectionInset.right) / CGFloat(columns))
        layout.estimatedItemSize = CGSize(width: side, height: side * sqrt(2))
        layout.itemSize = CGSize(width: side, height: side * sqrt(2))
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        needUpdateSizes()
        return fetchedResultController.sections!.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections![0].numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         designsDelegate?.present(design: fetchedResultController.object(at: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarDesignCollectionViewCell
        cell.update(with: fetchedResultController.object(at: indexPath))
        return cell
    }

    var blockOperations = [BlockOperation]()

    // MARK: - NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation {
                self.insertItems(at: [newIndexPath!])
            })
        case .update:
            blockOperations.append(BlockOperation {
                self.reloadItems(at: [indexPath!])
            })
        case .delete:
            blockOperations.append(BlockOperation {
                self.deleteItems(at: [indexPath!])
            })
        case .move:
            blockOperations.append(BlockOperation {
                self.moveItem(at: indexPath!, to: newIndexPath!)
            })
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        performBatchUpdates({ blockOperations.forEach { $0.start() } }, completion: nil)
    }

}
