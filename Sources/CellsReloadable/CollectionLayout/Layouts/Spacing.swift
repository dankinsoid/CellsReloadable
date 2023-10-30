import Foundation

public struct Spacing: CollectionLayout {
    
    public var properties: LayoutProperties {
        LayoutProperties(priority: 0)
    }
    
    public var items: [ViewCell] { [] }
    
    public init() {
    }
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        CGSize(
            width: proposal.width ?? 0,
            height: proposal.height ?? 0
        )
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
    }
}
