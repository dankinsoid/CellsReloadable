import Foundation

public struct ForEachLayout<Data: Sequence, ID: Hashable, Content: CollectionLayout>: CollectionLayout {
    
    public let data: Data
    public let getID: (Data.Element) -> ID
    public let content: (Data.Element) -> Content
    
    public init(_ data: Data, id: @escaping (Data.Element) -> ID, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        getID = id
        self.content = content
    }
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Cache) -> CGSize {
        .zero
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        data.enumerated().forEach {
            content($0.element)
                .placeSubviews(
                    in: bounds,
                    context: context.with(id: id(for: $0.element, id: context.localID)),
                    cache: &cache.caches[$0.offset],
                    place: place
                )
        }
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        data.forEach {
            content($0).makeItems(visitor: &visitor, localID: id(for: $0, id: localID))
        }
    }
    
    public func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        data.forEach {
            content($0).makeLayouts(visitor: &visitor, localID: id(for: $0, id: localID))
        }
    }
    
    public func createCache() -> Cache {
        Cache(caches: data.map { content($0).createCache() })
    }
    
    public struct Cache {
        
        var caches: [Content.Cache]
    }
    
    private func id(for element: Data.Element, id: AnyHashable) -> AnyHashable {
        UnionID(id, getID(element))
    }
}

extension ForEachLayout where Data.Element: Identifiable, ID == Data.Element.ID {
    
    public init(_ data: Data, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}

extension ForEachLayout where Data.Element: Hashable, ID == Data.Element {
    
    @_disfavoredOverload
    public init(_ data: Data, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, id: { $0 }, content: content)
    }
}
