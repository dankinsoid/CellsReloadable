import SwiftUI

final class HostingView<Content: View>: UIView {
    
    private let hostingController: HostingController<Content>
    var rootView: Content {
        get { hostingController.rootView }
        set {
            hostingController.rootView = newValue
            hostingController.view.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        hostingController.view.intrinsicContentSize
    }
    
    init(_ rootView: Content) {
        hostingController = HostingController<Content>(rootView: rootView)
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        var nextResponder = next
        while nextResponder != nil {
            if let viewController = nextResponder as? UIViewController {
                set(parentController: viewController)
                break
            }
            nextResponder = nextResponder?.next
        }
    }
    
    func set(parentController: UIViewController) {
        hostingController.rootView = rootView
        hostingController.view.invalidateIntrinsicContentSize()
        
        let requiresControllerMove = hostingController.parent != parentController
        if requiresControllerMove {
            // remove old parent if exists
            removeHostingControllerFromParent()
            parentController.addChild(hostingController)
        }
        
        if !subviews.contains(hostingController.view) {
            addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            hostingController.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        if requiresControllerMove {
            hostingController.didMove(toParent: parentController)
        }
    }
    
    override func invalidateIntrinsicContentSize() {
        hostingController.view.invalidateIntrinsicContentSize()
        super.invalidateIntrinsicContentSize()
    }
    
    // TODO: check https://github.dev/SwiftUIX/SwiftUIX/tree/master
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        hostingController.view.systemLayoutSizeFitting(targetSize)
//        hostingController.sizeThatFits(.init(targetSize: targetSize))
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        hostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
//        hostingController.sizeThatFits(
//            .init(
//                targetSize: targetSize,
//                horizontalFittingPriority: horizontalFittingPriority,
//                verticalFittingPriority: verticalFittingPriority
//            )
//        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        hostingController.sizeThatFits(in: size)
//        systemLayoutSizeFitting(size)
    }
    
//    override func sizeToFit() {
//        if let superview = superview {
//            frame.size = hostingController.sizeThatFits(in: superview.frame.size)
//        } else {
//            frame.size = hostingController.sizeThatFits(nil)
//        }
//    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }
    
    private func removeHostingControllerFromParent() {
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
        hostingController.didMove(toParent: nil)
    }
    
    deinit {
        removeHostingControllerFromParent()
    }
}

private final class HostingController<Content: View>: UIHostingController<Content> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.invalidateIntrinsicContentSize()
    }
}
