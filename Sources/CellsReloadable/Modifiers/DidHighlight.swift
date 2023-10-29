import UIKit

extension ViewCell.Values {
    
    /// The action to perform when the cell is highlighted.
    public var didHighlight: (UIView, Bool) -> Void {
        get { self[\.didHighlight] ?? { _, _ in } }
        set { self[\.didHighlight] = newValue }
    }
}

extension ViewCellConvertible {
    
    /// Creates a new instance of `ViewCell` with onHighlight action.
    public func didHighlight<V: UIView>(_ type: V.Type, _ action: @escaping (V, Bool) -> Void) -> ViewCell {
        combine(\.didHighlight) {
            if let view = $0 as? V {
                action(view, $1)
            }
        }
    }
}
