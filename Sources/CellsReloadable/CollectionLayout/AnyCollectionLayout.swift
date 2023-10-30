import UIKit

public struct AnyCollectionLayout: CollectionLayout {
    
    private let _createCache: () -> Any
    private let _sizeThatFits: (ProposedSize, LayoutContext, inout Any) -> CGSize
    private let _placeSubviews: (CGRect, LayoutContext, inout Any, (ViewCell, CGRect) -> Void) -> Void
    private let _makeItems: (inout AnyViewCellsVisitor, AnyHashable) -> Void
    private let _makeLayouts: (inout AnyLayoutVisitor, AnyHashable) -> Void
    public let properties: LayoutProperties
    
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
        _makeItems = {
            layout.makeItems(visitor: &$0, localID: $1)
        }
        _makeLayouts = {
            layout.makeLayouts(visitor: &$0, localID: $1)
        }
        properties = layout.properties
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
        place: (ViewCell, CGRect) -> Void
    ) {
        _placeSubviews(bounds, context, &cache, place)
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        var anyVisitor = AnyViewCellsVisitor(visitor)
        _makeItems(&anyVisitor, localID)
    }
    
    public func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        var anyVisitor = AnyLayoutVisitor(visitor)
        _makeLayouts(&anyVisitor, localID)
    }
}

private struct AnyViewCellsVisitor: ViewCellsVisitor {
    
    private var visitor: any ViewCellsVisitor
    
    init(_ visitor: any ViewCellsVisitor) {
        self.visitor = visitor
    }
    
    mutating func visit(with cells: [ViewCell]) {
        visitor.visit(with: cells)
    }
}

private struct AnyLayoutVisitor: LayoutVisitor {
    
    private var visitor: any LayoutVisitor
    
    init(_ visitor: any LayoutVisitor) {
        self.visitor = visitor
    }
    
    mutating func visit(with layout: some CollectionLayout) {
        visitor.visit(with: layout)
    }
}
