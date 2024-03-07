import SwiftUI

extension NSLayoutConstraint.Axis {
    
    var opposite: NSLayoutConstraint.Axis {
        switch self {
        case .horizontal:
            return .vertical
        case .vertical:
            return .horizontal
        default:
            return self
        }
    }
}

extension CGSize {
    
    init(_ axis: NSLayoutConstraint.Axis, _ value: CGFloat, _ other: CGFloat) {
        switch axis {
        case .horizontal:
            self.init(width: value, height: other)
        case .vertical:
            self.init(width: other, height: value)
        default:
            self = .zero
        }
    }
}

extension CGPoint {
    
    init(_ axis: NSLayoutConstraint.Axis, _ value: CGFloat, _ other: CGFloat) {
        switch axis {
        case .horizontal:
            self.init(x: value, y: other)
        case .vertical:
            self.init(x: other, y: value)
        default:
            self = .zero
        }
    }
}

extension Axis {
    
    var sizeKP: WritableKeyPath<CGSize, CGFloat> {
        switch self {
        case .horizontal:
            return \.width
        case .vertical:
            return \.height
        }
    }
}

extension CGRect {
    
    func frame(size: CGSize, alignment: Alignment) -> CGRect {
        var result = CGRect(origin: .zero, size: size)
        result.origin.x = switch alignment.horizontal {
        case .center:
            origin.x + (width - size.width) / 2
        case .right:
            origin.x + width - size.width
        default:
            origin.x
        }
        result.origin.y = switch alignment.vertical {
        case .bottom, .lastTextBaseline:
            origin.y + height - size.height
        case .center:
            origin.y + (height - size.height) / 2
        default:
            origin.y
        }
        return result
    }
}

private extension HorizontalAlignment {
    
    static var left: HorizontalAlignment {
        UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .trailing : .leading
    }
    
    static var right: HorizontalAlignment {
        UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .leading : .trailing
    }
}
