import UIKit

extension UIScrollView {

    var _isScrolling: Bool {
        isTracking || isDragging || isDecelerating
    }
}
