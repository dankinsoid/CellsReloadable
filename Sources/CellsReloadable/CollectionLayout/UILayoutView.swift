import UIKit

open class UILayoutView: UIView {
    
    var id: AnyHashable = NoneID()
    private var layout = AnyCollectionLayout(Spacing())
    private var layoutViews: [AnyHashable: UIView] = [:]
    private var needReload = true
    private var lastSize: CGSize?
    private var size: CGSize? {
        didSet {
            guard size != oldValue else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        size ?? CGSize(
            width: UIView.noIntrinsicMetric,
            height: UIView.noIntrinsicMetric
        )
    }
    
    open func reload<L: CollectionLayout>(with layout: () -> L) {
        let layout = layout()
        self.layout = AnyCollectionLayout(layout)
        reload()
    }
    
    open func reloadIfNeeded() {
        if needReload {
            reload()
        }
    }
    
    open func setNeedsReload() {
        needReload = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        reloadIfNeeded()
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let context = LayoutContext(
            localID: id,
            subviews: LayoutSubviews { [weak self] id in
                self?.layoutViews[id]
            } size: { _ in
                .zero
            }
        )
        var cache = layout.createCache()
        let proposal = ProposedSize(frame.size)
        return layout.sizeThatFits(
            proposal: proposal,
            context: context,
            cache: &cache
        )
    }
    
    private func reload() {
        let currentViews = layoutViews
        layoutViews = [:]
        
        var cache = layout.createCache()
        
        let proposal = ProposedSize.unspecified
        
        let context = LayoutContext(
            localID: id,
            subviews: LayoutSubviews { [weak self] id in
                currentViews[id] ?? self?.layoutViews[id]
            } size: { _ in
                .zero
            }
        )
        let size = layout.sizeThatFits(
            proposal: proposal,
            context: context,
            cache: &cache
        )
        
        layout.placeSubviews(
            in: CGRect(origin: .zero, size: size),
            context: context,
            cache: &cache
        ) { item, rect in
            let view = currentViews[id] ?? item.createView()
            layoutViews[id] = view
            item.reloadView(view)
            if view.superview == nil {
                addSubview(view)
            }
            view.frame = rect
        }
        for (id, view) in currentViews where layoutViews[id] == nil {
            view.removeFromSuperview()
        }
        self.size = size
    }
}
