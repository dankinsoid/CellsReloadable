import UIKit

public extension CollectionLayout {
    
    func background<L: CollectionLayout>(@LayoutBuilder _ background: () -> L) -> some CollectionLayout {
        BackgroundLayout(base: layout, background: background().layout)
    }
}

private struct BackgroundLayout<Base: CustomCollectionLayout, Background: CustomCollectionLayout>: CustomCollectionLayout {
    
    let base: Base
    let background: Background
    
    init(base: Base, background: Background) {
        self.base = base
        self.background = background
    }
    
    var properties: LayoutProperties {
        base.properties
    }
    
    func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout Cache) -> ProposedSize {
        base.sizeThatFits(proposal: size, context: context, cache: &cache.base)
    }
    
    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        background.placeSubviews(in: bounds, context: context.withID(Self.backgroundID), cache: &cache.background, place: place)
        base.placeSubviews(in: bounds, context: context.withID(Self.baseID), cache: &cache.base, place: place)
    }
    
    func createCache() -> Cache {
        Cache(base: base.createCache(), background: background.createCache())
    }

    func makeItems(localID: some Hashable) -> [ViewCell] {
        background.makeItems(localID: Self.backgroundID(for: localID)) +
        base.makeItems(localID: Self.baseID(for: localID))
    }

    func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        base.makeLayouts(localID: Self.baseID(for: localID)).map {
            AnyCollectionLayout(
                BackgroundLayout<AnyCollectionLayout, Background>(
                    base: $0,
                    background: background
                )
            )
        }
    }

    private static func backgroundID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \BackgroundLayout.background)
    }
    
    private static func baseID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \BackgroundLayout.base)
    }
    
    struct Cache {
        
        var base: Base.Layout.Cache
        var background: Background.Layout.Cache
    }
}
