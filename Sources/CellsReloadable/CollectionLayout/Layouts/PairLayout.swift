import Foundation

struct PairLayout<L: CollectionLayout, R: CollectionLayout>: CustomCollectionLayout {

    let l: L.Layout
    let r: R.Layout
    
    init(l: L, r: R) {
        self.l = l.layout
        self.r = r.layout
    }

    func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout Cache) -> ProposedSize {
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

        var l: L.Layout.Cache
        var r: R.Layout.Cache
    }

    func makeItems(localID: some Hashable) -> [ViewCell] {
        l.makeItems(localID: Self.firstID(for: localID)) +
        r.makeItems(localID: Self.secondID(for: localID))
    }

    func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        l.makeLayouts(localID: Self.firstID(for: localID)) +
        r.makeLayouts(localID: Self.secondID(for: localID))
    }

    static func firstID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \Self.l)
    }

    static func secondID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, \Self.r)
    }
}
