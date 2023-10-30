import UIKit

public struct LayoutProperties {
    
    public var axis: NSLayoutConstraint.Axis?
    public var priority: Double
    
    public init(
        axis: NSLayoutConstraint.Axis? = nil,
        priority: Double = 1
    ) {
        self.axis = axis
        self.priority = priority
    }
}
