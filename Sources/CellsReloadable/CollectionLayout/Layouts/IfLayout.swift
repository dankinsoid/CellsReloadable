import Foundation

enum IfLayout<L: CollectionLayout, S: CollectionLayout>: CollectionLayout {
    
    case first(L)
    case second(S)
    
    func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Cache) -> CGSize {
        switch (self, cache) {
        case (.first(let l), .first(var lCache)):
            let result = l.sizeThatFits(proposal: proposal, context: context, cache: &lCache)
            cache = .first(lCache)
            return result
        case (.second(let s), .second(var sCache)):
            let result = s.sizeThatFits(proposal: proposal, context: context, cache: &sCache)
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
    
    func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        switch self {
        case .first(let l):
            l.makeItems(visitor: &visitor, localID: Self.firstID(for: localID))
        case .second(let s):
            s.makeItems(visitor: &visitor, localID: Self.secondID(for: localID))
        }
    }
    
    func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        switch self {
        case .first(let l):
            l.makeLayouts(visitor: &visitor, localID: Self.firstID(for: localID))
        case .second(let s):
            s.makeLayouts(visitor: &visitor, localID: Self.secondID(for: localID))
        }
    }
    
    enum Cache {
        
        case first(L.Cache)
        case second(S.Cache)
    }
    
    static func firstID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, true)
    }
    
    static func secondID(for id: AnyHashable) -> AnyHashable {
        UnionID(id, false)
    }
}
