import Foundation

public struct EmptyLayout: CollectionLayout {
    
    public init() {}
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        .zero
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
    }
    
    public func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
    }
}
