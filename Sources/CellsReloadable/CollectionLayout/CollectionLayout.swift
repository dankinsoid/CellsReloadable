import UIKit

public protocol CollectionLayout {

    associatedtype Cache = Void

    var properties: LayoutProperties { get }
    var items: [ViewCell] { get }

    func createCache() -> Cache

    func sizeThatFits(
        proposal: ProposedSize,
        context: LayoutContext,
        cache: inout Cache
    ) -> CGSize

    func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Cache,
        place: (String, CGRect) -> Void
    )
}

extension CollectionLayout {

    public var properties: LayoutProperties { LayoutProperties() }
}

public struct HLayout: CollectionLayout {

    public var properties: LayoutProperties {
        LayoutProperties(
            axis: .horizontal,
            priority: max(1, children.map(\.properties.priority).max() ?? 1)
        )
    }
    
    public var items: [ViewCell] {
        children.flatMap(\.items)
    }

    public var spacing: Double = 0
    private let children: [AnyCollectionLayout]

    public init(
        spacing: Double = 0,
        @LayoutBuilder children: () -> [AnyCollectionLayout]
    ) {
        self.children = children()
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal: ProposedSize,
        context: LayoutContext,
        cache: inout Cache
    ) -> CGSize {
        guard !children.isEmpty else { return .zero }
        let fullSpacing = spacing * Double(children.count - 1)
        var unspecifiedSizes = children.indices.map {
            children[$0].sizeThatFits(
                proposal: ProposedSize(height: proposal.height),
                context: context,
                cache: &cache.caches[$0]
            )
        }
        var unspecifiedSize = unspecifiedSizes.reduce(into: CGSize.zero) { partialResult, itemSize in
            partialResult.height = max(partialResult.height, itemSize.height)
            partialResult.width += itemSize.width
        }
        unspecifiedSize.width += fullSpacing
        
        if let width = proposal.width, width != unspecifiedSize.width {
            let dif = width - unspecifiedSize.width
            add(
                dif,
                to: &unspecifiedSizes,
                layouts: children,
                axis: .horizontal,
                context: context,
                caches: &cache.caches
            )
            unspecifiedSize = unspecifiedSizes.reduce(into: CGSize.zero) { partialResult, itemSize in
                partialResult.height = max(partialResult.height, itemSize.height)
                partialResult.width += itemSize.width
            }
        }
        cache.subviewsSizes = unspecifiedSizes
        return unspecifiedSize
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Cache,
        place: (String, CGRect) -> Void
    ) {
        guard !children.isEmpty else { return }
        if cache.subviewsSizes.isEmpty {
            _ = sizeThatFits(
                proposal: ProposedSize(bounds.size),
                context: context,
                cache: &cache
            )
        }
        var originX = bounds.minX
        for i in children.indices {
            let rect = CGRect(
                origin: CGPoint(x: originX, y: 0),
                size: cache.subviewsSizes[i]
            )
            children[i].placeSubviews(
                in: rect,
                context: context,
                cache: &cache.caches[i],
                place: place
            )
            originX += cache.subviewsSizes[i].width + cache.spacing
        }
    }
    
    public struct Cache {
        
        var spacing: Double
        var caches: [Any]
        var subviewsSizes: [CGSize] = []
    }
    
    public func createCache() -> Cache {
        Cache(
            spacing: spacing,
            caches: children.map {
                $0.createCache()
            }
        )
    }
}

public class CollectionView: UICollectionView {
    
    private lazy var loader = UICollectionViewReloader(self)
    private let layout = CellsSectionLayout()
    private var lastSize: CGSize?
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: self.layout)
    }
    
    required public init?(coder: NSCoder) {
        super.init(frame: .zero, collectionViewLayout: self.layout)
    }
    
    public func reload<L: CollectionLayout>(items: () -> L) {
        let items = items()
        layout.layout = AnyCollectionLayout(items)
        loader.reload(cells: items.items, completion: nil)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if lastSize != frame.size, window != nil {
            lastSize = frame.size
            layout.invalidateLayout()
        }
    }
}

open class CellsSectionLayout: UICollectionViewLayout {
    
    private var allAttributes: [UICollectionViewLayoutAttributes] = []
    private var ids: [String] = []
    private var hasWindow = false
    var layout = AnyCollectionLayout(Spacing())
    private var size = CGSize.zero
    
    override open func prepare() {
        guard let collectionView else { return }
        let oldAttributes = hasWindow ? Dictionary(zip(ids, allAttributes)) { _, new in new } : [:]
        allAttributes = []
        hasWindow = collectionView.window != nil
        
        var cache = layout.createCache()

        var proposal: ProposedSize = .unspecified
        var origin = CGPoint.zero
        if let axis = layout.properties.axis {
            switch axis {
            case .horizontal:
                let dy = collectionView.adjustedContentInset.bottom + collectionView.adjustedContentInset.top
                origin.y = collectionView.adjustedContentInset.top
                proposal.height = collectionView.frame.height - dy
            case .vertical:
                let dx = collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right
                origin.x = collectionView.adjustedContentInset.left
                proposal.width = collectionView.frame.width - dx
            @unknown default:
                break
            }
        }
        
        let context = LayoutContext(
            subviews: LayoutSubviews { id in
                collectionView.reloader?.viewForItem(with: id)
            } size: { id in
                oldAttributes[id]?.frame.size
            }
        )
        size = layout.sizeThatFits(
            proposal: proposal,
            context: context,
            cache: &cache
        )
        
        layout.placeSubviews(
            in: CGRect(origin: origin, size: size),
            context: context,
            cache: &cache
        ) { id, rect in
            let attributes = UICollectionViewLayoutAttributes(
                forCellWith: IndexPath(item: allAttributes.count, section: 0)
            )
            attributes.frame = rect
            allAttributes.append(attributes)
        }
        ids = layout.items.map(\.id)
    }
    
    override open var collectionViewContentSize: CGSize {
        size
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        allAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        allAttributes[indexPath.item]
    }
}

open class UILayoutView: UIView {
    
    private var layout = AnyCollectionLayout(Spacing())
    private var layoutViews: [String: UIView] = [:]
    private var needReload = true
    private var lastSize: CGSize?
    private var size: CGSize? {
        didSet {
            guard size != oldValue else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        size ?? CGSize(
            width: UIView.noIntrinsicMetric,
            height: UIView.noIntrinsicMetric
        )
    }
    
    open func reload<L: CollectionLayout>(with layout: () -> L) {
        let layout = layout()
        self.layout = AnyCollectionLayout(layout)
        reload()
    }
    
    open func reloadIfNeeded() {
        if needReload {
            reload()
        }
    }
    
    open func setNeedsReload() {
        needReload = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        reloadIfNeeded()
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let context = LayoutContext(
            subviews: LayoutSubviews { [weak self] id in
                self?.layoutViews[id]
            } size: { _ in
                .zero
            }
        )
        var cache = layout.createCache()
        let proposal = ProposedSize(frame.size)
        return layout.sizeThatFits(
            proposal: proposal,
            context: context,
            cache: &cache
        )
    }
    
    private func reload() {
        let currentViews = layoutViews
        layoutViews = [:]
        
        var cache = layout.createCache()

        let proposal = ProposedSize.unspecified
        
        let context = LayoutContext(
            subviews: LayoutSubviews { [weak self] id in
                currentViews[id] ?? self?.layoutViews[id]
            } size: { _ in
                .zero
            }
        )
        let size = layout.sizeThatFits(
            proposal: proposal,
            context: context,
            cache: &cache
        )
        let items = layout.items
        
        layout.placeSubviews(
            in: CGRect(origin: .zero, size: size),
            context: context,
            cache: &cache
        ) { id, rect in
            let item: ViewCell?
            if items[safe: layoutViews.count]?.id == id {
                item = items[layoutViews.count]
            } else {
                item = items.first(where: { $0.id == id })
            }
            guard let item else { return }
            let view = currentViews[id] ?? item.createView()
            layoutViews[id] = view
            item.reloadView(view)
            if view.superview == nil {
                addSubview(view)
            }
            view.frame = rect
        }
        for (id, view) in currentViews where layoutViews[id] == nil {
            view.removeFromSuperview()
        }
        self.size = size
    }
}

public struct LayoutContainer<Layout: CollectionLayout>: CollectionLayout {
    
    public var id: String
    public var layout: Layout
    public var items: [ViewCell] {
        [
            ViewCell(id: id) {
                UILayoutView()
            } render: {
                $0.reload {
                    layout
                }
            }
        ]
    }
    
    public var properties: LayoutProperties { layout.properties }
    
    public init(id: String, layout: () -> Layout) {
        self.id = id
        self.layout = layout()
    }
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Layout.Cache) -> CGSize {
        if let view = context.subviews.view(for: id) as? UILayoutView {
            view.reloadIfNeeded()
            return view.intrinsicContentSize
        }
        return layout.sizeThatFits(proposal: proposal, context: context, cache: &cache)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Layout.Cache,
        place: (String, CGRect) -> Void
    ) {
        place(id, bounds)
    }
    
    public func createCache() -> Layout.Cache {
        layout.createCache()
    }
}

extension CollectionLayout where Cache == Void {
    
    public func createCache() -> Void {
    }
}

public struct ProposedSize: Hashable {
    
    public var width: Double?
    public var height: Double?
    
    public init(width: Double? = nil, height: Double? = nil) {
        self.width = width
        self.height = height
    }
    
    public init(_ size: CGSize) {
        self.width = size.width
        self.height = size.height
    }
    
    public static var zero: ProposedSize {
        ProposedSize(width: 0, height: 0)
    }
    
    public static var unspecified: ProposedSize {
        ProposedSize(width: nil, height: nil)
    }
    
    public static var infinity: ProposedSize {
        ProposedSize(width: .infinity, height: .infinity)
    }
}

public struct LayoutProperties {
    
    public var axis: NSLayoutConstraint.Axis?
    public var priority: Double
    
    public init(
        axis: NSLayoutConstraint.Axis? = nil,
        priority: Double = 1
    ) {
        self.axis = axis
        self.priority = priority
    }
}

public struct AnyCollectionLayout: CollectionLayout {
    
    private let _createCache: () -> Any
    private let _sizeThatFits: (ProposedSize, LayoutContext, inout Any) -> CGSize
    private let _placeSubviews: (CGRect, LayoutContext, inout Any, (String, CGRect) -> Void) -> Void
    public let properties: LayoutProperties
    public let items: [ViewCell]
    
    public init<L: CollectionLayout>(_ layout: L) {
        _createCache = layout.createCache
        _sizeThatFits = {
            guard var cache = $2 as? L.Cache else { return .zero }
            let result = layout.sizeThatFits(proposal: $0, context: $1, cache: &cache)
            $2 = cache
            return result
        }
        _placeSubviews = {
            guard var cache = $2 as? L.Cache else { return }
            layout.placeSubviews(in: $0, context: $1, cache: &cache, place: $3)
            $2 = cache
        }
        properties = layout.properties
        items = layout.items
    }
    
    public func createCache() -> Any {
        _createCache()
    }
    
    public func sizeThatFits(
        proposal: ProposedSize,
        context: LayoutContext,
        cache: inout Any
    ) -> CGSize {
        _sizeThatFits(proposal, context, &cache)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Any,
        place: (String, CGRect) -> Void
    ) {
        _placeSubviews(bounds, context, &cache, place)
    }
}

func add(
    _ value: Double,
    to sizes: inout [CGSize],
    layouts: [AnyCollectionLayout],
    axis: NSLayoutConstraint.Axis,
    context: LayoutContext,
    caches: inout [Any]
) {
    guard value != 0 else { return }
    var value = value
    let groups = Dictionary(grouping: layouts.enumerated(), by: \.element.properties.priority)
        .lazy
        .sorted {
            $0.key < $1.key
        }
        .map(\.value)
    for group in groups {
        let eachValue = value / Double(group.count)
        for (i, layout) in group {
            let oldValue = sizes[i][keyPath: axis.sizeKP]
            sizes[i] = layout.sizeThatFits(
                proposal: ProposedSize(
                    axis,
                    sizes[i][keyPath: axis.sizeKP] + eachValue,
                    other: sizes[i][keyPath: axis.oposite.sizeKP]
                ),
                context: context,
                cache: &caches[i]
            )
            let newValue = sizes[i][keyPath: axis.sizeKP]
            value -= (newValue - oldValue)
        }
        if abs(value) <= 0.001 {
            return
        }
    }
}

@resultBuilder
public enum LayoutBuilder {
    
    
    public static func buildBlock(_ components: [AnyCollectionLayout]...) -> [AnyCollectionLayout] {
        Array(components.joined())
    }
    
    @inlinable
    public static func buildArray(_ components: [[AnyCollectionLayout]]) -> [AnyCollectionLayout] {
        Array(components.joined())
    }
    
    @inlinable
    public static func buildEither(first component: [AnyCollectionLayout]) -> [AnyCollectionLayout] {
        component
    }
    
    @inlinable
    public static func buildEither(second component: [AnyCollectionLayout]) -> [AnyCollectionLayout] {
        component
    }
    
    @inlinable
    public static func buildOptional(_ component: [AnyCollectionLayout]?) -> [AnyCollectionLayout] {
        component ?? []
    }
    
    @inlinable
    public static func buildLimitedAvailability(_ component: [AnyCollectionLayout]) -> [AnyCollectionLayout] {
        component
    }
    
    @inlinable
    public static func buildExpression<L: CollectionLayout>(_ expression: L) -> [AnyCollectionLayout] {
        [AnyCollectionLayout(expression)]
    }
}

private extension NSLayoutConstraint.Axis {
    
    var oposite: NSLayoutConstraint.Axis {
        switch self {
        case .horizontal: return .vertical
        case .vertical: return .horizontal
        }
    }
    
    var sizeKP: WritableKeyPath<CGSize, CGFloat> {
        switch self {
        case .horizontal: return \.width
        case .vertical: return \.height
        }
    }
    
    var proposedSizeKP: WritableKeyPath<ProposedSize, Double?> {
        switch self {
        case .horizontal: return \.width
        case .vertical: return \.height
        }
    }
}

extension ProposedSize {
    
    init(
        _ axis: NSLayoutConstraint.Axis,
        _ value: Double?,
        other: Double?
    ) {
        switch axis {
        case .horizontal: self.init(width: value, height: other)
        case .vertical: self.init(width: other, height: value)
        }
    }
}

func tt() -> some CollectionLayout {
    HLayout(spacing: 10) {
        Spacing()
        ViewCell {
            UILabel()
        } render: { label in
            label.text = "100"
        }
        Spacing()
    }
}

extension ViewCell: CollectionLayout {
    
    public var items: [ViewCell] { [self] }

    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        if let view = context.subviews.view(for: id) {
            if proposal == .unspecified {
                let intrinsic = view.intrinsicContentSize
                if intrinsic.width != UIView.noIntrinsicMetric, intrinsic.height != UIView.noIntrinsicMetric {
                    return intrinsic
                }
            }
            return view.systemLayoutSizeFitting(
                CGSize(
                    width: proposal.width ?? UIView.layoutFittingCompressedSize.width,
                    height: proposal.height ?? UIView.layoutFittingCompressedSize.height
                )
            )
        } else {
            return context.subviews.cachedSize(for: id) ?? CGSize(
                width: proposal.width ?? 100,
                height: proposal.height ?? 100
            )
        }
    }

    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (String, CGRect) -> Void) {
        place(id, bounds)
    }
}

public struct LayoutContext {
    
    public var environments: ()
    public var subviews: LayoutSubviews
    
    public init(
        subviews: LayoutSubviews,
        environments: () = ()
    ) {
        self.subviews = subviews
        self.environments = environments
    }
}

public struct LayoutSubviews {

    private let _view: (String) -> UIView?
    private let _size: (String) -> CGSize?

    public init(
        view: @escaping (String) -> UIView?,
        size: @escaping (String) -> CGSize?
    ) {
        _view = view
        _size = size
    }

    public func view(for id: String) -> UIView? {
        _view(id)
    }
    
    public func cachedSize(for id: String) -> CGSize? {
        _size(id)
    }
}

public struct Spacing: CollectionLayout {
    
    public var properties: LayoutProperties {
        LayoutProperties(priority: 0)
    }
    
    public var items: [ViewCell] { [] }
    
    public init() {
    }
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        CGSize(
            width: proposal.width ?? 0,
            height: proposal.height ?? 0
        )
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (String, CGRect) -> Void) {
    }
}

private struct BackgroundLayout<Base: CollectionLayout, Background: CollectionLayout>: CollectionLayout {
    
    let base: Base
    let background: Background
    var properties: LayoutProperties {
        base.properties
    }
    
    var items: [ViewCell] {
        background.items + base.items
    }

    func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Cache) -> CGSize {
        base.sizeThatFits(proposal: proposal, context: context, cache: &cache.base)
    }
    
    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (String, CGRect) -> Void) {
        background.placeSubviews(in: bounds, context: context, cache: &cache.background, place: place)
        base.placeSubviews(in: bounds, context: context, cache: &cache.base, place: place)
    }
    
    func createCache() -> Cache {
        Cache(base: base.createCache(), background: background.createCache())
    }
    
    struct Cache {
        var base: Base.Cache
        var background: Background.Cache
    }
}

public struct ColorLayout: CollectionLayout {
    
    public var properties: LayoutProperties {
        LayoutProperties(priority: 0)
    }
    
    public let color: UIColor
    public let id: String
    
    public var items: [ViewCell] {
        [
            ViewCell(id: id) {
                UIView()
            } render: { cell in
                cell.backgroundColor = color
            }
        ]
    }
    
    public init(id: String, _ color: UIColor) {
        self.color = color
        self.id = id
    }
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        CGSize(
            width: proposal.width ?? 0,
            height: proposal.height ?? 0
        )
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (String, CGRect) -> Void) {
        place(id, bounds)
    }
}

public extension CollectionLayout {
    
    func background<L: CollectionLayout>(_ background: () -> L) -> some CollectionLayout {
        BackgroundLayout(base: self, background: background())
    }
}

private struct SizeLayout<Base: CollectionLayout>: CollectionLayout {
    
    let base: Base
    var width: Double?
    var height: Double?
    var minWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var maxHeight: Double?
    
    var properties: LayoutProperties {
        var result = base.properties
        result.priority = 1
        return result
    }
    var items: [ViewCell] { base.items }
    
    func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Base.Cache) -> CGSize {
        if let width, let height {
            return CGSize(width: width, height: height)
        } else {
            let sizeThatFits = base.sizeThatFits(
                proposal: ProposedSize(
                    width: width(for: proposal.width),
                    height: height(for: proposal.height)
                ),
                context: context,
                cache: &cache
            )
            return CGSize(
                width: width(for: sizeThatFits.width) ?? sizeThatFits.width,
                height: height(for: sizeThatFits.height) ?? sizeThatFits.height
            )
        }
    }
    
    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Base.Cache, place: (String, CGRect) -> Void) {
        base.placeSubviews(in: bounds, context: context, cache: &cache, place: place)
    }
    
    func createCache() -> Base.Cache {
        base.createCache()
    }
    
    private func height(for value: Double?) -> Double? {
        guard height == nil else { return height }
        guard let value else { return nil }
        return max(minHeight ?? value, min(maxHeight ?? value, value))
    }
    
    private func width(for value: Double?) -> Double? {
        guard width == nil else { return width }
        guard let value else { return nil }
        return max(minWidth ?? value, min(maxWidth ?? value, value))
    }
}

public extension CollectionLayout {
    
    func size(width: Double?, height: Double?) -> some CollectionLayout {
        SizeLayout(base: self, width: width, height: height)
    }
    
    func size(_ size: Double?) -> some CollectionLayout {
        SizeLayout(base: self, width: size, height: size)
    }
    
    func size(_ size: CGSize) -> some CollectionLayout {
        SizeLayout(base: self, width: size.width, height: size.height)
    }
    
    func size(width: Double?) -> some CollectionLayout {
        SizeLayout(base: self, width: width)
    }
    
    func size(height: Double?) -> some CollectionLayout {
        SizeLayout(base: self, height: height)
    }
    
    func size(
        minWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        maxHeight: Double? = nil
    ) -> some CollectionLayout {
        SizeLayout(base: self, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
    }
}
