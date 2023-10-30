import UIKit

public protocol CollectionLayout {

    associatedtype Cache = Void

    var properties: LayoutProperties { get }

    func createCache() -> Cache

    func sizeThatFits(
        proposal: ProposedSize,
        context: LayoutContext,
        cache: inout Cache
    ) -> CGSize

    func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Cache,
        place: (ViewCell, CGRect) -> Void
    )
    
    func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable)
    func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable)
}

extension CollectionLayout {

    public var properties: LayoutProperties { LayoutProperties() }
}

extension CollectionLayout where Cache == Void {
    
    public func createCache() -> Void {
    }
}

extension CollectionLayout {
    
    public func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        visitor.visit(with: self)
    }
}
