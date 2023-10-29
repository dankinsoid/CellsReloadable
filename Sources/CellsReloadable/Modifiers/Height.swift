import UIKit

public extension ViewCell.Values {
    
    /// The height of the cell, used in `UITableViewReloader`.
    var height: CGFloat? {
        get { self[\.height] ?? nil }
        set { self[\.height] = newValue }
    }
}

public extension ViewCellConvertible {
    
    /// Creates a new instance of `ViewCell` with row height, used in `UITableViewReloader`.
    func height(_ height: CGFloat) -> ViewCell {
        with(\.height, height)
    }
}
