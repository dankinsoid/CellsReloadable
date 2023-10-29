import UIKit

/// ```UICollectionViewReloader``` is a class that eliminates the need to work with the traditional datasource.
/// It allows you to directly deal with the data and the cell that should be displayed.
/// With this feature, you don't have to subclass `UICollectionViewCell`.
/// Instead, you can directly use `UIView` instances and make your codebase simpler and cleaner.
///
/// It's recommend to use `Identifiable` items for correct animations.
public final class UICollectionViewReloader: NSObject, CellsSectionsReloadable {

    public var isAnimated: Bool {
        didSet {
            configureDataSource()
        }
    }

    public private(set) var sections: [CellsSection] = []
    public private(set) weak var collectionView: UICollectionView?
    public weak var collectionViewDelegate: UICollectionViewDelegate?

    private var diffableDataSource: UniquelyCollectionDiffableDataSource<AnyHashable, ViewCell>?
    private var cellsByID: [AnyHashable: ViewCell] = [:]
    private var isFirstReload = true

    public init(
        _ collectionView: UICollectionView,
        isAnimated: Bool = false,
        delegate: UICollectionViewDelegate? = nil
    ) {
        self.isAnimated = isAnimated
        self.collectionView = collectionView
        super.init()
        collectionViewDelegate = delegate
        prepareCollectionView()
    }

    public func reloadData() {
        defer { isFirstReload = false }
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

public extension UICollectionView {

    var reloader: UICollectionViewReloader? {
        delegate as? UICollectionViewReloader
    }
}

public extension UICollectionViewReloader {

    func sectionValues(forSection section: Int) -> CellsSection.Values? {
        sections[safe: section]?.values
    }

    func viewCellForItem(at indexPath: IndexPath) -> ViewCell? {
        sections[safe: indexPath.section]?.cells[safe: indexPath.item]
    }

    func viewForItem(at indexPath: IndexPath) -> UIView? {
        (collectionView?.cellForItem(at: indexPath) as? AnyCollectionViewCell)?.cellView
    }

    func viewForItem(with id: AnyHashable) -> UIView? {
        guard let indexPath = indexPath(with: id) else {
            return nil
        }
        return viewForItem(at: indexPath)
    }

    func viewCellForItem(with id: AnyHashable) -> ViewCell? {
        guard let indexPath = indexPath(with: id) else {
            return nil
        }
        return viewCellForItem(at: indexPath)
    }

    func indexPath(with id: AnyHashable) -> IndexPath? {
        diffableDataSource?.indexPath(
            for: HashableByID(ViewCell(id: id) { UIView() }, id: \.id)
        )
    }

    var visibleViews: [UIView] {
        collectionView?.visibleCells.compactMap { ($0 as? AnyCollectionViewCell)?.cellView } ?? []
    }
}

extension UICollectionViewReloader: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sections[indexPath.section].cells[indexPath.item]
        return collectionView.dequeueReloadReusableCell(with: cell, for: indexPath)
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
        configureDataSource()
    }

    func reloadData(newValue: [CellsSection], completion: (() -> Void)? = nil) {
        defer { isFirstReload = false }
        sections = newValue
        guard let diffableDataSource else {
            reloadData()
            return
        }

        let snapshot = UniqueDiffableDataSourceSnapshot<AnyHashable, ViewCell>()
        snapshot.appendSections(newValue.map(\.id))
        for section in newValue {
            snapshot.appendItems(section.cells, toSection: section.id)
        }

        cellsByID = Dictionary(sections.flatMap { $0.cells.map { ($0.id, $0) } }) { _, new in new }
        let isAnimated = isAnimated && !isFirstReload && !snapshot.hasDuplicatedKeys
        if #available(iOS 15.0, *), !isAnimated {
            diffableDataSource.applySnapshotUsingReloadData(snapshot.snapshot, completion: completion)
        } else {
            diffableDataSource.apply(snapshot, animatingDifferences: isAnimated, completion: completion)
        }
    }

    func configureDataSource() {
        if isAnimated {
            createDataSourceIfNeeded()
        } else if diffableDataSource == nil {
            collectionView?.dataSource = self
        }
    }

    func createDataSourceIfNeeded() {
        guard let collectionView, diffableDataSource == nil else { return }
        diffableDataSource = UniquelyCollectionDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, cell in
            let newCell = self?.cellsByID[cell.id] ?? self?.sections[safe: indexPath.section]?.cells[safe: indexPath.row] ?? cell
            return collectionView.dequeueReloadReusableCell(with: newCell, for: indexPath)
        }
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

        static var registeredIDsKey = 0
    }
}

private final class AnyCollectionViewCell: UICollectionViewCell {

    var cellView: UIView?
    var onReuse: (UIView) -> Void = {_  in }
    var onHighlight: (UIView, Bool) -> Void = { _, _ in }

    override var isHighlighted: Bool {
        didSet {
            if let cellView {
                onHighlight(cellView, isHighlighted)
            }
        }
    }

    func reload(cell: ViewCell) {
        guard cell.typeIdentifier == reuseIdentifier else { return }
        onReuse = cell.values.willReuse
        onHighlight = cell.values.didHighlight
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
        if let cellView {
            onReuse(cellView)
        }
        if let reusableView = cellView as? UICollectionReusableView {
            reusableView.prepareForReuse()
        }
    }
}
