import UIKit

extension NSLayoutConstraint.Axis {
    
    var sizeKP: WritableKeyPath<CGSize, CGFloat> {
        switch self {
        case .horizontal: return \.width
        case .vertical: return \.height
        @unknown default: return \.width
        }
    }
    
    var proposedSizeKP: WritableKeyPath<ProposedSize, Double?> {
        switch self {
        case .horizontal: return \.width
        case .vertical: return \.height
        @unknown default: return \.width
        }
    }
}

func max<T: Comparable>(_ items: T?...) -> T? {
    var result: T? = nil
    for item in items {
        if let item = item {
            result = max(result ?? item, item)
        } else {
            return nil
        }
    }
    return result
}

func min<T: Comparable>(_ items: T?...) -> T? {
    var result: T? = nil
    for item in items {
        if let item = item {
            result = min(result ?? item, item)
        } else {
            return nil
        }
    }
    return result
}
