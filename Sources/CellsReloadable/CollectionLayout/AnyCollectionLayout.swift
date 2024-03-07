import UIKit

public struct AnyCollectionLayout: CustomCollectionLayout {
    
    private let _createCache: () -> Any
    private let _sizeThatFits: (ProposedSize, LayoutContext, inout Any) -> ProposedSize
    private let _placeSubviews: (CGRect, LayoutContext, inout Any, (ViewCell, CGRect) -> Void) -> Void
    private let _makeItems: (AnyHashable) -> [ViewCell]
    private let _makeLayouts: (AnyHashable) -> [AnyCollectionLayout]
    public let properties: LayoutProperties
    
    public init<L: CollectionLayout>(_ layout: L) {
        let layout = layout.layout
        _createCache = layout.createCache
        _sizeThatFits = {
            guard var cache = $2 as? L.Layout.Cache else { return .zero }
            let result = layout.sizeThatFits(proposal: $0, context: $1, cache: &cache)
            $2 = cache
            return result
        }
        _placeSubviews = {
            guard var cache = $2 as? L.Layout.Cache else { return }
            layout.placeSubviews(in: $0, context: $1, cache: &cache, place: $3)
            $2 = cache
        }
        _makeItems = {
            layout.makeItems(localID: $0)
        }
        _makeLayouts = {
            layout.makeLayouts(localID: $0)
        }
        properties = layout.properties
    }
    
    public func createCache() -> Any {
        _createCache()
    }
    
    public func sizeThatFits(
        proposal size: ProposedSize,
        context: LayoutContext,
        cache: inout Any
    ) -> ProposedSize {
        _sizeThatFits(size, context, &cache)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Any,
        place: (ViewCell, CGRect) -> Void
    ) {
        _placeSubviews(bounds, context, &cache, place)
    }
    
    public func makeItems(localID: some Hashable) -> [ViewCell] {
        _makeItems(localID)
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        _makeLayouts(localID)
    }
}
