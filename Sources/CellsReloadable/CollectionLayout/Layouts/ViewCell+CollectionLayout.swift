import UIKit

extension CollectionLayout where Self: ViewCellConvertible {
    
    public func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout ()) -> CGSize {
        let id = updateIDIfNeeded(id: context.localID).id
        if let view = context.subviews.view(for: id) {
            if proposal == .unspecified {
                let intrinsic = view.intrinsicContentSize
                if intrinsic.width != UIView.noIntrinsicMetric, intrinsic.height != UIView.noIntrinsicMetric {
                    return intrinsic
                }
            }
            return view.systemLayoutSizeFitting(
                CGSize(
                    width: proposal.width ?? UIView.layoutFittingCompressedSize.width,
                    height: proposal.height ?? UIView.layoutFittingCompressedSize.height
                )
            )
        } else {
            return context.subviews.cachedSize(for: id) ?? CGSize(
                width: proposal.width ?? 100,
                height: proposal.height ?? 100
            )
        }
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
        place(updateIDIfNeeded(id: context.localID), bounds)
    }
    
    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        visitor.visit(with: [updateIDIfNeeded(id: localID)])
    }
    
    public func makeLayouts(visitor: inout some LayoutVisitor, localID: some Hashable) {
        visitor.visit(with: updateIDIfNeeded(id: localID))
    }
}

extension ViewCell: CollectionLayout {}
extension TypedViewCell: CollectionLayout {}
