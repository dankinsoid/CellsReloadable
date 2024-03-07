import Foundation

public struct ForEachLayout<Data: Sequence, ID: Hashable, Content: CollectionLayout>: CustomCollectionLayout {
    
    public let data: Data
    public let getID: (Data.Element) -> ID
    public let content: (Data.Element) -> Content
    
    public init(_ data: Data, id: @escaping (Data.Element) -> ID, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        getID = id
        self.content = content
    }
    
    public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout Cache) -> ProposedSize {
        .zero
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        data.enumerated().forEach {
            content($0.element).layout
                .placeSubviews(
                    in: bounds,
                    context: context.with(id: id(for: $0.element, id: context.localID)),
                    cache: &cache.caches[$0.offset],
                    place: place
                )
        }
    }

    public func makeItems(localID: some Hashable) -> [ViewCell] {
        data.flatMap {
            content($0).layout
                .makeItems(localID: id(for: $0, id: localID))
        }
    }

    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        data.flatMap {
            content($0).layout
                .makeLayouts(localID: id(for: $0, id: localID))
        }
    }
    
    public func createCache() -> Cache {
        Cache(caches: data.map { content($0).layout.createCache() })
    }
    
    public struct Cache {
        
        var caches: [Content.Layout.Cache]
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
