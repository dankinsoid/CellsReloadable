import Foundation

extension Optional: CollectionLayout where Wrapped: CollectionLayout {
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Wrapped.Cache?) -> CGSize {
        if let self, var wrappedCache = cache {
            let result = self.sizeThatFits(proposal: proposal, context: context, cache: &wrappedCache)
            cache = wrappedCache
            return result
        } else {
            return .zero
        }
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Wrapped.Cache?, place: (ViewCell, CGRect) -> Void) {
        if let self, var wrappedCache = cache {
            self.placeSubviews(in: bounds, context: context, cache: &wrappedCache, place: place)
            cache = wrappedCache
        }
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        self?.makeItems(visitor: &visitor, localID: localID)
    }
    
    public func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        self?.makeLayouts(visitor: &visitor, localID: localID)
    }
    
    public func createCache() -> Wrapped.Cache? {
        self?.createCache()
    }
}
