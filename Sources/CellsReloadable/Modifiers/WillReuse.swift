import UIKit

extension ViewCell.Values {
    
    /// The action to perform when the cell is prepared to reuse.
    public var willReuse: (UIView) -> Void {
        get { self[\.willReuse] ?? { _ in } }
        set { self[\.willReuse] = newValue }
    }
}

extension ViewCellConvertible {
    
    /// Creates a new instance of `ViewCell` with onReuse action.
    public func willReuse<V: UIView>(_ type: V.Type, _ action: @escaping (V) -> Void) -> ViewCell {
        combine(\.willReuse) {
            if let view = $0 as? V {
                action(view)
            }
        }
    }
}
