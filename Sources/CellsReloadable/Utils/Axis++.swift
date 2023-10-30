import UIKit

extension NSLayoutConstraint.Axis {
    
    var oposite: NSLayoutConstraint.Axis {
        switch self {
        case .horizontal: return .vertical
        case .vertical: return .horizontal
        @unknown default: return self
        }
    }
    
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
