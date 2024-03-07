import Foundation

public struct EmptyLayout: CustomCollectionLayout {
    
    public init() {}
    
    public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout ()) -> ProposedSize {
        .zero
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
    }
    
    public func makeItems(localID: some Hashable) -> [ViewCell] {
        []
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        []
    }
}
