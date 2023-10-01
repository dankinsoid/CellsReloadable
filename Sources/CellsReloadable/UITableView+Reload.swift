import UIKit

/// ```UITableViewSource``` is a class that eliminates the need to work with the traditional datasource.
/// It allows you to directly deal with the data and the cell that should be displayed.
/// With this feature, you don't have to subclass `UITableViewCell`.
/// Instead, you can directly use `UIView` instances and make your codebase simpler and cleaner.
///
/// It's recommend to use `Identifiable` items for correct animations.
///
public final class UITableViewSource: NSObject, CellsSectionsReloadable {

    public var defaultRowAnimation: UITableView.RowAnimation {
        get { diffableDataSource.defaultRowAnimation }
        set { diffableDataSource.defaultRowAnimation = newValue }
    }

    private(set) public weak var tableView: UITableView?
    public weak var tableViewDelegate: UITableViewDelegate?
    
    private let diffableDataSource: UniquelyTableDiffableDataSource<CellsSection.Values, ViewCell>

    public init(
        _ tableView: UITableView,
        animation: UITableView.RowAnimation = .automatic,
        delegate: UITableViewDelegate? = nil
    ) {
        diffableDataSource = UniquelyTableDiffableDataSource(tableView)
        tableViewDelegate = delegate
        super.init()
        defaultRowAnimation = animation
        prepareTableView()
    }

    public func sections() -> [CellsSection] {
        diffableDataSource.snapshot().sections()
    }

    public func reloadData() {
        tableView?.reloadData()
    }

    public func reload(sections: [CellsSection], completion: (() -> Void)? = nil) {
        reloadData(newValue: sections, completion: completion)
    }

    public override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return tableViewDelegate?.responds(to: aSelector) ?? false
    }

    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if tableViewDelegate?.responds(to: aSelector) == true {
            return tableViewDelegate
        }
        return super.forwardingTarget(for: aSelector)
    }
}

public extension CellsSection.Values {

    var footer: ViewCell? {
        self[\.footer] ?? nil
    }

    var header: ViewCell? {
        self[\.header] ?? nil
    }
}

public extension ViewCell.Values {

    var height: CGFloat? {
        self[\.height] ?? nil
    }
}

extension UITableViewSource: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let method = tableViewDelegate?.tableView(_:heightForRowAt:) {
            return method(tableView, indexPath)
        }
        guard let cell = viewCell(for: indexPath) else { return tableView.rowHeight }
        return cell.values.height ?? tableView.rowHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let method = tableViewDelegate?.tableView(_:viewForHeaderInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionData(for: section), let header = section.header else { return nil }
        return tableView.dequeueReloadReusableHeaderFooterView(with: header)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let method = tableViewDelegate?.tableView(_:heightForHeaderInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionData(for: section), let header = section.header else { return tableView.sectionHeaderHeight }
        return header.values.height ?? tableView.sectionHeaderHeight
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let method = tableViewDelegate?.tableView(_:viewForFooterInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionData(for: section), let footer = section.footer else { return nil }
        return tableView.dequeueReloadReusableHeaderFooterView(with: footer)
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let method = tableViewDelegate?.tableView(_:heightForFooterInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionData(for: section), let footer = section.footer else { return tableView.sectionFooterHeight }
        return footer.values.height ?? tableView.sectionFooterHeight
    }
}

public extension UITableView {

    func dequeueReloadReusableCell(with item: ViewCell, for indexPath: IndexPath) -> UITableViewCell {
        registerIfNeeded(cell: item)
        guard let cellView = dequeueReusableCell(withIdentifier: item.typeIdentifier, for: indexPath) as? AnyTableViewCell else {
            return UITableViewCell()
        }
        cellView.reload(cell: item)
        return cellView
    }

    func dequeueReloadReusableHeaderFooterView(with item: ViewCell) -> UITableViewHeaderFooterView? {
        registerIfNeeded(headerFooter: item)
        let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: item.typeIdentifier)
        guard let anyHeaderFooter = headerFooter as? AnyTableHeaderFooterView else { return headerFooter }
        anyHeaderFooter.reload(cell: item)
        return anyHeaderFooter
    }
}

private extension UITableViewSource {

    func prepareTableView() {
        guard let tableView else { return }
        if tableView.delegate !== self {
            tableViewDelegate = tableView.delegate
        }
        tableView.delegate = self
    }

    func reloadData(newValue: [CellsSection], completion: (() -> Void)?) {
        diffableDataSource.reload(sections: newValue, completion: completion)
    }

    func sectionData(for section: Int) -> CellsSection.Values? {
        let snapshot = diffableDataSource.snapshot()
        return snapshot.sectionIdentifiers[safe: section]?.value
    }

    func viewCell(for indexPath: IndexPath) -> ViewCell? {
        let snapshot = diffableDataSource.snapshot()
        guard let sectionID = snapshot.sectionIdentifiers[safe: indexPath.section] else { return nil }
        return snapshot.itemIdentifiers(inSection: sectionID)[safe: indexPath.row]?.value
    }
}

extension UniquelyTableDiffableDataSource<CellsSection.Values, ViewCell>: ViewCellsReloadable {}

extension UniquelyTableDiffableDataSource<CellsSection.Values, ViewCell>: CellsSectionsReloadable {

    func reload(sections: [CellsSection], completion: (() -> Void)?) {
        let snapshot = UniqueDiffableDataSourceSnapshot<CellsSection.Values, ViewCell>()
        snapshot.reload(sections: sections, completion: nil)
        apply(snapshot, animatingDifferences: defaultRowAnimation != .none, completion: completion)
    }
}

extension UniquelyTableDiffableDataSource where ItemIdentifierType == ViewCell {

    convenience init(_ tableView: UITableView) {
        self.init(tableView: tableView) { tableView, indexPath, cell in
            tableView.dequeueReloadReusableCell(with: cell, for: indexPath)
        }
    }
}

public extension NSDiffableDataSourceSnapshot<HashableByID<CellsSection.Values, AnyHashable>, HashableByID<ViewCell, AnyHashable>> {

    func sections() -> [CellsSection] {
        sectionIdentifiers.map {
            CellsSection(values: $0.value, cells: itemIdentifiers(inSection: $0).map(\.value))
        }
    }
}

private extension UITableView {

    func registerIfNeeded(cell: ViewCell) {
        guard !registeredCellsIDs.contains(cell.typeIdentifier) else { return }
        register(AnyTableViewCell.self, forCellReuseIdentifier: cell.typeIdentifier)
        registeredCellsIDs.insert(cell.typeIdentifier)
    }

    func registerIfNeeded(headerFooter: ViewCell) {
        guard !registeredFootersHeadersIDs.contains(headerFooter.typeIdentifier) else { return }
        register(AnyTableHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerFooter.typeIdentifier)
        registeredFootersHeadersIDs.insert(headerFooter.typeIdentifier)
    }

    var registeredCellsIDs: Set<String> {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.registeredICellsIDsKey) as? Set<String>) ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.registeredICellsIDsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var registeredFootersHeadersIDs: Set<String> {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.registeredIFootersHeadersIDsKey) as? Set<String>) ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.registeredIFootersHeadersIDsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    enum AssociatedKeys {

        static var registeredICellsIDsKey = "registeredICellsIDsKey"
        static var registeredIFootersHeadersIDsKey = "registeredIFootersHeadersIDsKey"
    }
}

private final class AnyTableViewCell: UITableViewCell {

    private var cellView: UIView?

    func reload(cell: ViewCell) {
        guard cell.typeIdentifier == reuseIdentifier else { return }
        let view: UIView
        if let cellView {
            view = cellView
        } else {
            if #available(iOS 14.0, *) {
                contentConfiguration = nil
                backgroundConfiguration = .clear()
            }
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
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let reusableView = cellView as? ReusableView {
            reusableView.prepareForReuse()
        }
    }
}

private final class AnyTableHeaderFooterView: UITableViewHeaderFooterView {

    private var cellView: UIView?

    func reload(cell: ViewCell) {
        guard cell.typeIdentifier == reuseIdentifier else { return }
        let view: UIView
        if let cellView {
            view = cellView
        } else {
            if #available(iOS 14.0, *) {
                contentConfiguration = nil
                backgroundConfiguration = .clear()
            }
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
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let reusableView = cellView as? ReusableView {
            reusableView.prepareForReuse()
        }
    }
}
