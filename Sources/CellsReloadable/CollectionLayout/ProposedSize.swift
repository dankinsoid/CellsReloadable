import UIKit

public struct ProposedSize: Hashable {
    
    public var width: Double?
    public var height: Double?
    
    public init(width: Double? = nil, height: Double? = nil) {
        self.width = width
        self.height = height
    }
    
    public init(_ size: CGSize) {
        self.width = size.width
        self.height = size.height
    }
    
    public static var zero: ProposedSize {
        ProposedSize(width: 0, height: 0)
    }
    
    public static var unspecified: ProposedSize {
        ProposedSize(width: nil, height: nil)
    }
    
    public static var infinity: ProposedSize {
        ProposedSize(width: .infinity, height: .infinity)
    }
}

extension ProposedSize {
    
    init(
        _ axis: NSLayoutConstraint.Axis,
        _ value: Double?,
        other: Double?
    ) {
        switch axis {
        case .horizontal: self.init(width: value, height: other)
        case .vertical: self.init(width: other, height: value)
        @unknown default: self.init(width: nil, height: nil)
        }
    }
}
