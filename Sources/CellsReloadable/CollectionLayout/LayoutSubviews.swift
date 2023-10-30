import UIKit

public struct LayoutSubviews {
    
    private let _view: (AnyHashable) -> UIView?
    private let _size: (AnyHashable) -> CGSize?
    
    public init(
        view: @escaping (AnyHashable) -> UIView?,
        size: @escaping (AnyHashable) -> CGSize?
    ) {
        _view = view
        _size = size
    }
    
    public func view(for id: AnyHashable) -> UIView? {
        _view(id)
    }
    
    public func cachedSize(for id: AnyHashable) -> CGSize? {
        _size(id)
    }
}
