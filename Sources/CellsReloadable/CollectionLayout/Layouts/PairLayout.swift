import Foundation

struct PairLayout<L: CollectionLayout, R: CollectionLayout>: CollectionLayout {

    let l: L
    let r: R

    func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Cache) -> CGSize {
        .zero
    }

    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        l.placeSubviews(in: bounds, context: context.withID(Self.firstID), cache: &cache.l, place: place)
        r.placeSubviews(in: bounds, context: context.withID(Self.secondID), cache: &cache.r, place: place)
    }

    func createCache() -> Cache {
        Cache(l: l.createCache(), r: r.createCache())
    }

    struct Cache {

        var l: L.Cache
        var r: R.Cache
    }

    func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        l.makeItems(visitor: &visitor, localID: Self.firstID(for: localID))
        r.makeItems(visitor: &visitor, localID: Self.secondID(for: localID))
    }

    func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        l.makeLayouts(visitor: &visitor, localID: Self.firstID(for: localID))
        r.makeLayouts(visitor: &visitor, localID: Self.secondID(for: localID))
    }
    
    static func firstID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \Self.l)
    }
    
    static func secondID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \Self.r)
    }
}
