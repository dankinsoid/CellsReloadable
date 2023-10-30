import UIKit

extension UIColor: CollectionLayout {

    public var properties: LayoutProperties {
        LayoutProperties(priority: 0)
    }

    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        CGSize(
            width: proposal.width ?? 0,
            height: proposal.height ?? 0
        )
    }

    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
        place(
            ViewCell(id: context.localID) {
                UIView()
            } render: { cell in
                cell.backgroundColor = self
            },
            bounds
        )
    }

    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        visitor.visit(
            with: [
                ViewCell(id: localID) {
                    UIView()
                } render: { cell in
                    cell.backgroundColor = self
                }
            ]
        )
    }
}
