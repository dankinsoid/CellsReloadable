import UIKit

public extension ViewCell.Values {
    
    /// The action to perform when the cell is selected.
    var didSelect: () -> Void {
        get { self[\.didSelect] ?? {} }
        set { self[\.didSelect] = newValue }
    }
    
    /// The action to perform before the cell is displayed.
    var willDisplay: () -> Void {
        get { self[\.willDisplay] ?? {} }
        set { self[\.willDisplay] = newValue }
    }
    
    /// The action to perform after the cell is displayed.
    var didEndDisplaying: () -> Void {
        get { self[\.didEndDisplaying] ?? {} }
        set { self[\.didEndDisplaying] = newValue }
    }
}

public extension ViewCellConvertible {
    
    /// Creates a new instance of `ViewCell` with didSelect action.
    func didSelect(_ didSelect: @escaping () -> Void) -> ViewCell {
        combine(\.didSelect, with: didSelect)
    }
    
    /// Creates a new instance of `ViewCell` with willDisplay action.
    func willDisplay(_ willDisplay: @escaping () -> Void) -> ViewCell {
        combine(\.willDisplay, with: willDisplay)
    }
    
    /// Creates a new instance of `ViewCell` with didEndDisplaying action.
    func didEndDisplaying(_ didEndDisplaying: @escaping () -> Void) -> ViewCell {
        combine(\.didEndDisplaying, with: didEndDisplaying)
    }
}
