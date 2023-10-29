import UIKit

public extension ViewCell.Values {
    
    /// The size of the cell, used in `UICollectionViewReloader`.
    var size: (_ bounds: CGSize) -> CGSize? {
        get { self[\.size] ?? { _ in nil } }
        set { self[\.size] = newValue }
    }
}

public extension ViewCell {
    
    /// Creates a new instance of `ViewCell` with size, used in `UICollectionViewReloader`.
    func size(_ size: @escaping (_ bounds: CGSize) -> CGSize?) -> ViewCell {
        with(\.size, size)
    }
}
