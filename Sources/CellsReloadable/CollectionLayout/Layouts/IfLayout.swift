import Foundation

enum IfLayout<L: CollectionLayout, S: CollectionLayout>: CustomCollectionLayout {

    case first(L.Layout)
    case second(S.Layout)

    func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout Cache) -> ProposedSize {
        switch (self, cache) {
        case (.first(let l), .first(var lCache)):
            let result = l.sizeThatFits(proposal: size, context: context, cache: &lCache)
            cache = .first(lCache)
            return result
        case (.second(let s), .second(var sCache)):
            let result = s.sizeThatFits(proposal: size, context: context, cache: &sCache)
            cache = .second(sCache)
            return result
        default:
            return .zero
        }
    }

    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        switch (self, cache) {
        case (.first(let l), .first(var lCache)):
            l.placeSubviews(in: bounds, context: context.withID(Self.firstID), cache: &lCache, place: place)
            cache = .first(lCache)
        case (.second(let s), .second(var sCache)):
            s.placeSubviews(in: bounds, context: context.withID(Self.secondID), cache: &sCache, place: place)
            cache = .second(sCache)
        default:
            return
        }
    }

    func createCache() -> Cache {
        switch self {
        case .first(let l):
            return .first(l.createCache())
        case .second(let s):
            return .second(s.createCache())
        }
    }

    func makeItems(localID: some Hashable) -> [ViewCell] {
        switch self {
        case .first(let l):
            l.makeItems(localID: Self.firstID(for: localID))
        case .second(let s):
            s.makeItems(localID: Self.secondID(for: localID))
        }
    }

    func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        switch self {
        case .first(let l):
            l.makeLayouts(localID: Self.firstID(for: localID))
        case .second(let s):
            s.makeLayouts(localID: Self.secondID(for: localID))
        }
    }

    enum Cache {

        case first(L.Layout.Cache)
        case second(S.Layout.Cache)
    }

    static func firstID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, true)
    }

    static func secondID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, false)
    }
}
