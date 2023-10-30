import UIKit

public struct HLayout<Content: CollectionLayout>: CollectionLayout {
    
    public var properties: LayoutProperties {
        var result = content.properties
        result.axis = .horizontal
        return result
    }
    
    public var spacing: Double = 0
    public let content: Content
    
    public init(
        spacing: Double = 0,
        @LayoutBuilder content: () -> Content
    ) {
        self.content = content()
        self.spacing = spacing
    }
    
    public func sizeThatFits(
        proposal: ProposedSize,
        context: LayoutContext,
        cache: inout Cache
    ) -> CGSize {
        var visitor = HLayoutVisitor()
        content.makeLayouts(visitor: &visitor, localID: context.localID)
        let children = visitor.layouts
        cache.children = children
        if cache.caches.count != children.count {
            cache.caches = children.map {
                $0.createCache()
            }
        }
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
        place: (ViewCell, CGRect) -> Void
    ) {
        let children = cache.children
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
        var children: [AnyCollectionLayout] = []
    }
    
    public func createCache() -> Cache {
        Cache(
            spacing: spacing,
            caches: []
        )
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        content.makeItems(visitor: &visitor, localID: localID)
    }
}

private struct HLayoutVisitor: LayoutVisitor {
    
    var layouts: [AnyCollectionLayout] = []
    
    mutating func visit(with layout: some CollectionLayout) {
        layouts.append(AnyCollectionLayout(layout))
    }
}

private func add(
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
