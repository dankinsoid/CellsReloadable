import Foundation

public struct Spacing: CustomCollectionLayout {
    
    public var properties: LayoutProperties {
        LayoutProperties(priority: 0)
    }
    
    public var items: [ViewCell] { [] }
    
    public init() {
    }
    
    public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout ()) -> ProposedSize {
        size
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
    }
    
    public func makeItems(localID: some Hashable) -> [ViewCell] {
        []
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        [AnyCollectionLayout(self)]
    }
}
