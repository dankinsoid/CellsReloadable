import UIKit

//public struct LayoutContainer<Content: CollectionLayout>: CustomCollectionLayout {
//    
//    public var layout: Content.Layout
//    
//    public var properties: LayoutProperties { layout.properties }
//
//    public init(@LayoutBuilder layout: () -> Content) {
//        self.layout = layout().layout
//    }
//    
//    public func sizeThatFits(proposal size: CGSize, context: LayoutContext, cache: inout Content.Layout.Cache) -> CGSize {
//        if let view = context.subviews.view(for: context.localID) as? UILayoutView {
//            view.reloadIfNeeded()
//            return view.intrinsicContentSize
//        }
//        return layout.sizeThatFits(proposal: size, context: context, cache: &cache)
//    }
//    
//    public func placeSubviews(
//        in bounds: CGRect,
//        context: LayoutContext,
//        cache: inout Content.Layout.Cache,
//        place: (ViewCell, CGRect) -> Void
//    ) {
//        place(
//            ViewCell(id: context.localID) {
//                UILayoutView()
//            } render: {
//                $0.id = context.localID
//                $0.reload {
//                    layout
//                }
//            },
//            bounds
//        )
//    }
//    
//    public func createCache() -> Content.Layout.Cache {
//        layout.createCache()
//    }
//
//    public func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
//        visitor.visit(
//            with:  [
//                ViewCell(id: localID) { () -> UILayoutView in
//                    let result = UILayoutView()
//                    result.id = localID
//                    return result
//                } render: {
//                    $0.reload {
//                        layout
//                    }
//                }
//            ]
//        )
//    }
//}
