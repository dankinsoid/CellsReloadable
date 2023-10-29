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
        didSet {
            diffableDataSource?.defaultRowAnimation = rowAnimation(for: defaultRowAnimation)
            configureDataSource()
        }
    }

    public private(set) var sections: [CellsSection] = []

    public private(set) weak var tableView: UITableView?
    public weak var tableViewDelegate: UITableViewDelegate?

    private var isFirstReload = true
    private var cellsByID: [AnyHashable: ViewCell] = [:]
    private var diffableDataSource: UniquelyTableDiffableDataSource<AnyHashable, ViewCell>?

    public init(
        _ tableView: UITableView,
        animation: UITableView.DirectionalRowAnimation = .none,
        delegate: UITableViewDelegate? = nil
    ) {
        self.tableView = tableView
        tableViewDelegate = delegate
        defaultRowAnimation = animation
        super.init()
        prepareTableView()
    }

    public func reloadData() {
        defer { isFirstReload = false }
        tableView?.reloadData()
    }

    public func reload(sections: [CellsSection], completion: (() -> Void)? = nil) {
        reloadData(newValue: sections, completion: completion)
    }

    // swiftlint:disable implicitly_unwrapped_optional
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
        sections[safe: section]?.values
    }

    func viewCellForRow(at indexPath: IndexPath) -> ViewCell? {
        sections[safe: indexPath.section]?.cells[safe: indexPath.row]
    }

    func viewForRow(at indexPath: IndexPath) -> UIView? {
        (tableView?.cellForRow(at: indexPath) as? AnyTableViewCell)?.cellView
    }

    func viewForRow(with id: AnyHashable) -> UIView? {
        guard let indexPath = indexPath(with: id) else {
            return nil
        }
        return viewForRow(at: indexPath)
    }

    func viewCellForRow(with id: AnyHashable) -> ViewCell? {
        guard let indexPath = indexPath(with: id) else {
            return nil
        }
        return viewCellForRow(at: indexPath)
    }

    func indexPath(with id: AnyHashable) -> IndexPath? {
        diffableDataSource?.indexPath(
            for: HashableByID(ViewCell(id: id) { UIView() }, id: \.id)
        )
    }

    func headerView(forSection section: Int) -> UIView? {
        (tableView?.headerView(forSection: section) as? AnyTableHeaderFooterView)?.cellView
    }

    func footerView(forSection section: Int) -> UIView? {
        (tableView?.footerView(forSection: section) as? AnyTableHeaderFooterView)?.cellView
    }

    var visibleViews: [UIView] {
        tableView?.visibleCells.compactMap { ($0 as? AnyTableViewCell)?.cellView } ?? []
    }
}

// swiftlint:disable redundant_nil_coalescing
public extension CellsSection.Values {

    /// The header of the section.
    var footer: ViewCell? {
        get { self[\.footer] ?? nil }
        set { self[\.footer] = newValue }
    }

    /// The footer of the section.
    var header: ViewCell? {
        get { self[\.header] ?? nil }
        set { self[\.header] = newValue }
    }
}

public extension CellsSection {

    /// Creates a new instance of `CellsSection` with footer.
    func footer(@SingleViewCellBuilder _ footer: () -> ViewCell) -> Self {
        with(\.footer, footer())
    }

    /// Creates a new instance of `CellsSection` with header.
    func header(@SingleViewCellBuilder _ header: () -> ViewCell) -> Self {
        with(\.header, header())
    }
}

extension UITableViewReloader: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cells[indexPath.row]
        return tableView.dequeueReloadReusableCell(with: cell, for: indexPath)
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
                return .leastNormalMagnitude
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
                return .leastNormalMagnitude
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
        configureDataSource()
    }

    func reloadData(newValue: [CellsSection], completion: (() -> Void)?) {
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
        let isAnimated = defaultRowAnimation != .none && !isFirstReload && !snapshot.hasDuplicatedKeys
        if #available(iOS 15.0, *), !isAnimated {
            diffableDataSource.applySnapshotUsingReloadData(snapshot.snapshot, completion: completion)
        } else {
            diffableDataSource.apply(snapshot, animatingDifferences: isAnimated, completion: completion)
        }
    }

    func configureDataSource() {
        if defaultRowAnimation != .none {
            createDataSourceIfNeeded()
        } else if diffableDataSource == nil {
            tableView?.dataSource = self
        }
    }

    func createDataSourceIfNeeded() {
        guard let tableView, diffableDataSource == nil else { return }
        diffableDataSource = UniquelyTableDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, cell in
            let newCell = self?.cellsByID[cell.id] ?? self?.sections[safe: indexPath.section]?.cells[safe: indexPath.row] ?? cell
            return tableView.dequeueReloadReusableCell(with: newCell, for: indexPath)
        }
        diffableDataSource?.defaultRowAnimation = rowAnimation(for: defaultRowAnimation)
    }

    func directionalRowAnimation(for animation: UITableView.RowAnimation) -> UITableView.DirectionalRowAnimation {
        switch animation {
        case .fade: return .fade
        case .right: return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .leading : .trailing
        case .left: return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .trailing : .leading
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
        case .leading: return tableView?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        case .top: return .top
        case .bottom: return .bottom
        case .none: return .none
        case .middle: return .middle
        case .automatic: return .automatic
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

        static var registeredICellsIDsKey = 0
        static var registeredIFootersHeadersIDsKey = 1
    }
}

private final class AnyTableViewCell: UITableViewCell {

    var cellView: UIView?
    var onReuse: (UIView) -> Void = { _ in }
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
        if let cellView {
            onReuse(cellView)
        }
        if let reusableView = cellView as? UICollectionReusableView {
            reusableView.prepareForReuse()
        }
    }
}

private final class AnyTableHeaderFooterView: UITableViewHeaderFooterView {

    var cellView: UIView?
    var onReuse: (UIView) -> Void = { _ in }

    func reload(cell: ViewCell) {
        guard cell.typeIdentifier == reuseIdentifier else { return }
        onReuse = cell.values.willReuse
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
        if let cellView {
            onReuse(cellView)
        }
        if let reusableView = cellView as? UICollectionReusableView {
            reusableView.prepareForReuse()
        }
    }
}
