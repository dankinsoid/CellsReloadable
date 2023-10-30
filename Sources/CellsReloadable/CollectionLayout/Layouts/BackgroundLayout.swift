import UIKit

public extension CollectionLayout {
    
    func background<L: CollectionLayout>(_ background: () -> L) -> some CollectionLayout {
        BackgroundLayout(base: self, background: background())
    }
}

private struct BackgroundLayout<Base: CollectionLayout, Background: CollectionLayout>: CollectionLayout {
    
    let base: Base
    let background: Background
    var properties: LayoutProperties {
        base.properties
    }
    
    func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Cache) -> CGSize {
        base.sizeThatFits(proposal: proposal, context: context, cache: &cache.base)
    }
    
    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        background.placeSubviews(in: bounds, context: context.withID(Self.backgroundID), cache: &cache.background, place: place)
        base.placeSubviews(in: bounds, context: context.withID(Self.baseID), cache: &cache.base, place: place)
    }
    
    func createCache() -> Cache {
        Cache(base: base.createCache(), background: background.createCache())
    }
    
    func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        background.makeItems(visitor: &visitor, localID: Self.backgroundID(for: localID))
        base.makeItems(visitor: &visitor, localID: Self.baseID(for: localID))
    }
    
    private static func backgroundID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \BackgroundLayout.background)
    }
    
    private static func baseID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \BackgroundLayout.base)
    }
    
    struct Cache {
        
        var base: Base.Cache
        var background: Background.Cache
    }
}
