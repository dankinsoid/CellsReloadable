import UIKit

/// ```UICollectionViewReloader``` is a class that eliminates the need to work with the traditional datasource.
/// It allows you to directly deal with the data and the cell that should be displayed.
/// With this feature, you don't have to subclass `UICollectionViewCell`.
/// Instead, you can directly use `UIView` instances and make your codebase simpler and cleaner.
///
/// It's recommend to use `Identifiable` items for correct animations.
public final class UICollectionViewReloader: NSObject, CellsSectionsReloadable {

    public var isAnimated: Bool
    private(set) public weak var collectionView: UICollectionView?
    public weak var collectionViewDelegate: UICollectionViewDelegate?

    private let diffableDataSource: UniquelyCollectionDiffableDataSource<CellsSection.Values, ViewCell>

    public init(
        _ collectionView: UICollectionView,
        isAnimated: Bool = true,
        delegate: UICollectionViewDelegate? = nil
    ) {
        self.isAnimated = isAnimated
        self.collectionView = collectionView
        diffableDataSource = UniquelyCollectionDiffableDataSource(collectionView)
        super.init()
        collectionViewDelegate = delegate
        prepareCollectionView()
    }

    public func sections() -> [CellsSection] {
        diffableDataSource.snapshot().sections()
    }

    public func reloadData() {
        collectionView?.reloadData()
    }

    public func reload(sections: [CellsSection], completion: (() -> Void)? = nil) {
        reloadData(newValue: sections, completion: completion)
    }

    public override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return collectionViewDelegate?.responds(to: aSelector) ?? false
    }

    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if collectionViewDelegate?.responds(to: aSelector) == true {
            return collectionViewDelegate
        }
        return super.forwardingTarget(for: aSelector)
    }
}

public extension UICollectionViewReloader {

    func sectionValues(forSection section: Int) -> CellsSection.Values? {
        let snapshot = diffableDataSource.snapshot()
        return snapshot.sectionIdentifiers[safe: section]?.value
    }

    func viewCellForItem(at indexPath: IndexPath) -> ViewCell? {
        let snapshot = diffableDataSource.snapshot()
        guard let sectionID = snapshot.sectionIdentifiers[safe: indexPath.section] else { return nil }
        return snapshot.itemIdentifiers(inSection: sectionID)[safe: indexPath.row]?.value
    }
    
    func viewForItem(at indexPath: IndexPath) -> UIView? {
        (collectionView?.cellForItem(at: indexPath) as? AnyCollectionViewCell)?.cellView
    }
}

extension UICollectionViewReloader: UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if
            let flowDelegate = collectionViewDelegate as? UICollectionViewDelegateFlowLayout,
            let method = flowDelegate.collectionView(_:layout:sizeForItemAt:) {
            return method(collectionView, collectionViewLayout, indexPath)
        }

        let originalSize = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
        guard let viewCell = viewCellForItem(at: indexPath) else { return originalSize }
        return viewCell.values.size(collectionView.frame.size) ?? originalSize
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        collectionViewDelegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
        viewCellForItem(at: indexPath)?.values.willDisplay()
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        collectionViewDelegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        viewCellForItem(at: indexPath)?.values.didEndDisplaying()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewDelegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        viewCellForItem(at: indexPath)?.values.didSelect()
    }
}

public extension ViewCell.Values {

    var size: (CGSize) -> CGSize? { self[\.size] ?? { _ in nil } }
}

public extension UICollectionView {

    func dequeueReloadReusableCell(with item: ViewCell, for indexPath: IndexPath) -> UICollectionViewCell {
        registerIfNeeded(cell: item)
        guard let cellView = dequeueReusableCell(withReuseIdentifier: item.typeIdentifier, for: indexPath) as? AnyCollectionViewCell else {
            return UICollectionViewCell()
        }
        cellView.reload(cell: item)
        return cellView
    }
}

private extension UICollectionViewReloader {

    func prepareCollectionView() {
        guard let collectionView else { return }
        if collectionView.delegate !== self {
            collectionViewDelegate = collectionView.delegate
        }
        collectionView.delegate = self
    }

    func reloadData(newValue: [CellsSection], completion: (() -> Void)? = nil) {
        let snapshot = UniqueDiffableDataSourceSnapshot<CellsSection.Values, ViewCell>()
        snapshot.reload(sections: newValue, completion: nil)
        diffableDataSource.apply(snapshot, animatingDifferences: isAnimated, completion: completion)
    }
}

private extension UICollectionView {

    func registerIfNeeded(cell: ViewCell) {
        guard !registeredIDs.contains(cell.typeIdentifier) else { return }
        register(AnyCollectionViewCell.self, forCellWithReuseIdentifier: cell.typeIdentifier)
        registeredIDs.insert(cell.typeIdentifier)
    }

    private var registeredIDs: Set<String> {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.registeredIDsKey) as? Set<String>) ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.registeredIDsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private enum AssociatedKeys {

        static var registeredIDsKey = "registeredIDsKey"
    }
}

extension UniquelyCollectionDiffableDataSource<CellsSection.Values, ViewCell>: ViewCellsReloadable {}

extension UniquelyCollectionDiffableDataSource<CellsSection.Values, ViewCell>: CellsSectionsReloadable {

    func reload(sections: [CellsSection], completion: (() -> Void)?) {
        let snapshot = UniqueDiffableDataSourceSnapshot<CellsSection.Values, ViewCell>()
        snapshot.reload(sections: sections, completion: nil)
        apply(snapshot, animatingDifferences: true, completion: completion)
    }
}

extension UniquelyCollectionDiffableDataSource where ItemIdentifierType == ViewCell {

    convenience init(_ collectionView: UICollectionView) {
        self.init(collectionView: collectionView) { collectionView, indexPath, cell in
            collectionView.dequeueReloadReusableCell(with: cell, for: indexPath)
        }
    }
}

private final class AnyCollectionViewCell: UICollectionViewCell {

    var cellView: UIView?

    func reload(cell: ViewCell) {
        guard cell.typeIdentifier == reuseIdentifier else { return }
        let view: UIView
        if let cellView {
            view = cellView
        } else {
            contentView.backgroundColor = .clear
            backgroundColor = .clear
            view = cell.createView()
            add(view: view)
            cellView = view
        }
        cell.reloadView(view)
    }

    private func add(view: UIView) {
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let reusableView = cellView as? UICollectionReusableView {
            reusableView.prepareForReuse()
        } else if let reusableView = cellView as? ReusableView {
            reusableView.prepareForReuse()
        }
    }
}
