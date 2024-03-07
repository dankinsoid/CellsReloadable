import Foundation

extension Optional: CollectionLayout where Wrapped: CollectionLayout {
}

extension Optional: CustomCollectionLayout where Wrapped: CollectionLayout {
    
    public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout Wrapped.Layout.Cache?) -> ProposedSize {
        if let self, var wrappedCache = cache {
            let result = self.layout.sizeThatFits(proposal: size, context: context, cache: &wrappedCache)
            cache = wrappedCache
            return result
        } else {
            return .zero
        }
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Wrapped.Layout.Cache?, place: (ViewCell, CGRect) -> Void) {
        if let self, var wrappedCache = cache {
            self.layout.placeSubviews(in: bounds, context: context, cache: &wrappedCache, place: place)
            cache = wrappedCache
        }
    }
    
    public func makeItems(localID: some Hashable) -> [ViewCell] {
        self?.layout.makeItems(localID: localID) ?? []
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        self?.layout.makeLayouts(localID: localID) ?? []
    }
    
    public func createCache() -> Wrapped.Layout.Cache? {
        self?.layout.createCache()
    }
}
