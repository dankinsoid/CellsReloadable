import UIKit

/// ```UITableViewReloader``` is a class that eliminates the need to work with the traditional datasource.
/// It allows you to directly deal with the data and the cell that should be displayed.
/// With this feature, you don't have to subclass `UITableViewCell`.
/// Instead, you can directly use `UIView` instances and make your codebase simpler and cleaner.
///
/// It's recommend to use `Identifiable` items for correct animations.
///
public final class UITableViewReloader: NSObject, CellsSectionsReloadable {

    public var defaultRowAnimation: UITableView.DirectionalRowAnimation {
        get { directionalRowAnimation(for: diffableDataSource.defaultRowAnimation) }
        set { diffableDataSource.defaultRowAnimation = rowAnimation(for: newValue) }
    }

    private(set) public weak var tableView: UITableView?
    public weak var tableViewDelegate: UITableViewDelegate?
    
    private let diffableDataSource: UniquelyTableDiffableDataSource<CellsSection.Values, ViewCell>

    public init(
        _ tableView: UITableView,
        animation: UITableView.DirectionalRowAnimation = .automatic,
        delegate: UITableViewDelegate? = nil
    ) {
        self.tableView = tableView
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

public extension UITableViewReloader {
    
    func sectionValues(forSection section: Int) -> CellsSection.Values? {
        let snapshot = diffableDataSource.snapshot()
        return snapshot.sectionIdentifiers[safe: section]?.value
    }
    
    func viewCellForRow(at indexPath: IndexPath) -> ViewCell? {
        let snapshot = diffableDataSource.snapshot()
        guard let sectionID = snapshot.sectionIdentifiers[safe: indexPath.section] else { return nil }
        return snapshot.itemIdentifiers(inSection: sectionID)[safe: indexPath.row]?.value
    }
    
    func viewForRow(at indexPath: IndexPath) -> UIView? {
        (tableView?.cellForRow(at: indexPath) as? AnyTableViewCell)?.cellView
    }
    
    func viewForRow(with id: String) -> UIView? {
        guard let indexPath = indexPath(with: id) else {
            return nil
        }
        return viewForRow(at: indexPath)
    }
    
    func viewCellForRow(with id: String) -> ViewCell? {
        guard let indexPath = indexPath(with: id) else {
            return nil
        }
        return viewCellForRow(at: indexPath)
    }
    
    func indexPath(with id: String) -> IndexPath? {
        diffableDataSource.indexPath(
            for: HashableByID(ViewCell { UIView() }) { _ in id }
        )
    }
    
    func headerView(forSection section: Int) -> UIView? {
        (tableView?.headerView(forSection: section) as? AnyTableHeaderFooterView)?.cellView
    }
    
    func footerView(forSection section: Int) -> UIView? {
        (tableView?.footerView(forSection: section) as? AnyTableHeaderFooterView)?.cellView
    }
}

public extension CellsSection.Values {

    /// The header of the section.
    var footer: ViewCell? {
        self[\.footer] ?? nil
    }

    /// The footer of the section.
    var header: ViewCell? {
        self[\.header] ?? nil
    }
}

public extension CellsSection {
    
    /// Creates a new instance of `CellsSection` with footer.
    func footer(_ footer: some ViewCellConvertible) -> Self {
        with(\.footer, footer.asViewCell)
    }
    
    /// Creates a new instance of `CellsSection` with header.
    func header(_ header: some ViewCellConvertible) -> Self {
        with(\.header, header.asViewCell)
    }
}

public extension ViewCell.Values {
    
    /// The height of the cell.
    var height: CGFloat? {
        self[\.height] ?? nil
    }
    
    /// The action to perform when the cell is selected.
    var didSelect: () -> Void {
        self[\.didSelect] ?? {}
    }
    
    var willDisplay: () -> Void { self[\.willDisplay] ?? {} }
    var didEndDisplaying: () -> Void { self[\.didEndDisplaying] ?? {} }
}

public extension ViewCell {
    
    /// Creates a new instance of `ViewCell` with row height.
    func height(_ height: CGFloat) -> Self {
        with(\.height, height)
    }
    
    /// Creates a new instance of `ViewCell` with didSelect action.
    func didSelect(_ didSelect: @escaping () -> Void) -> Self {
        with(\.didSelect, didSelect)
    }
}

extension UITableViewReloader: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let method = tableViewDelegate?.tableView(_:heightForRowAt:) {
            return method(tableView, indexPath)
        }
        guard let cell = viewCellForRow(at: indexPath) else { return tableView.rowHeight }
        return cell.values.height ?? tableView.rowHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let method = tableViewDelegate?.tableView(_:viewForHeaderInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionValues(forSection: section), let header = section.header else { return nil }
        return tableView.dequeueReloadReusableHeaderFooterView(with: header)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let method = tableViewDelegate?.tableView(_:heightForHeaderInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionValues(forSection: section), let header = section.header else {
            if tableView.sectionHeaderHeight == UITableView.automaticDimension {
                return 0.001
            } else {
                return tableView.sectionHeaderHeight
            }
        }
        return header.values.height ?? tableView.sectionHeaderHeight
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let method = tableViewDelegate?.tableView(_:viewForFooterInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionValues(forSection: section), let footer = section.footer else { return nil }
        return tableView.dequeueReloadReusableHeaderFooterView(with: footer)
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let method = tableViewDelegate?.tableView(_:heightForFooterInSection:) {
            return method(tableView, section)
        }
        guard let section = sectionValues(forSection: section), let footer = section.footer else {
            if tableView.sectionFooterHeight == UITableView.automaticDimension {
                return 0.001
            } else {
                return tableView.sectionFooterHeight
            }
        }
        return footer.values.height ?? tableView.sectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let method = tableViewDelegate?.tableView(_:didSelectRowAt:) {
            method(tableView, indexPath)
        }
        viewCellForRow(at: indexPath)?.values.didSelect()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let method = tableViewDelegate?.tableView(_:willDisplay:forRowAt:) {
            method(tableView, cell, indexPath)
        }
        viewCellForRow(at: indexPath)?.values.willDisplay()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let method = tableViewDelegate?.tableView(_:didEndDisplaying:forRowAt:) {
            method(tableView, cell, indexPath)
        }
        viewCellForRow(at: indexPath)?.values.didEndDisplaying()
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
    
    enum DirectionalRowAnimation: Int, @unchecked Sendable {
        
        case fade = 0
        case trailing = 1
        case leading = 2
        case top = 3
        case bottom = 4
        case none = 5
        case middle = 6
        case automatic = 100
    }
}

private extension UITableViewReloader {
    
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
    
    func directionalRowAnimation(for animation: UITableView.RowAnimation) -> UITableView.DirectionalRowAnimation {
        switch animation {
        case .fade: return .fade
        case .right: return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .leading : .trailing
        case .left:  return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .trailing : .leading
        case .top: return .top
        case .bottom: return .bottom
        case .none: return .none
        case .middle: return .middle
        case .automatic: return .automatic
        @unknown default: return .automatic
        }
    }
    
    func rowAnimation(for animation: UITableView.DirectionalRowAnimation) -> UITableView.RowAnimation {
        switch animation {
        case .fade: return .fade
        case .trailing: return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        case .leading:  return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        case .top: return .top
        case .bottom: return .bottom
        case .none: return .none
        case .middle: return .middle
        case .automatic: return .automatic
        }
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

extension NSDiffableDataSourceSnapshot<HashableByID<CellsSection.Values, AnyHashable>, HashableByID<ViewCell, AnyHashable>> {

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

    var cellView: UIView?

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

    var cellView: UIView?

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
