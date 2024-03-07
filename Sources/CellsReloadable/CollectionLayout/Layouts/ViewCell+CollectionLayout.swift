import UIKit

extension CustomCollectionLayout where Self: ViewCellConvertible {
    
    public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout ()) -> ProposedSize {
        let id = updateIDIfNeeded(id: context.localID).id
        if let view = context.subviews.view(for: id) {
            if size.width == .infinity, size.height == .infinity {
                let intrinsic = view.intrinsicContentSize
                if intrinsic.width != UIView.noIntrinsicMetric, intrinsic.height != UIView.noIntrinsicMetric {
                    return ProposedSize(intrinsic)
                }
            }
            let compressedSize = CGSize(
                width: size.width ?? UIView.layoutFittingCompressedSize.width,
                height: size.height ?? UIView.layoutFittingCompressedSize.height
            )
            if view.constraints.isEmpty {
                return ProposedSize(view.sizeThatFits(compressedSize))
            } else {
                return ProposedSize(view.systemLayoutSizeFitting(compressedSize))
            }
        } else {
            return context.subviews.cachedSize(for: id).map { ProposedSize($0) } ?? ProposedSize(
                width: size.width,
                height: size.height
            )
        }
    }
    
    public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
        place(updateIDIfNeeded(id: context.localID), bounds)
    }
}

extension ViewCell: CustomCollectionLayout {
    
    public func makeItems(localID: some Hashable) -> [ViewCell] {
        [updateIDIfNeeded(id: localID)]
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        [AnyCollectionLayout(updateIDIfNeeded(id: localID))]
    }
}

extension TypedViewCell: CustomCollectionLayout {
    
    public func makeItems(localID: some Hashable) -> [ViewCell] {
        [updateIDIfNeeded(id: localID)]
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        [AnyCollectionLayout(updateIDIfNeeded(id: localID))]
    }
}
