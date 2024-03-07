import UIKit

extension UIColor: CustomCollectionLayout {

    public var properties: LayoutProperties {
        LayoutProperties(priority: 0)
    }

    public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout ()) -> ProposedSize {
        size
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

    public func makeItems(localID: some Hashable) -> [ViewCell] {
        [
            ViewCell(id: localID) {
                UIView()
            } render: { cell in
                cell.backgroundColor = self
            }
        ]
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        [AnyCollectionLayout(self)]
    }
}
