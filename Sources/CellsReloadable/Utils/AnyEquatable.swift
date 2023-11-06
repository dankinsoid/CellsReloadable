import Foundation

public struct AnyEquatable: Equatable {
    
    public let base: Any
    private let isEqual: (Any, Any) -> Bool
    
    public static var unique: AnyEquatable {
        AnyEquatable(()) { _, _ in false }
    }
    
    public static var none: AnyEquatable {
        AnyEquatable(()) { _, _ in true }
    }
    
    public init<T>(_ base: T, isEqual: @escaping (T, T) -> Bool) {
        self.base = base
        self.isEqual = {
            guard let lhs = $0 as? T, let rhs = $1 as? T else {
                return false
            }
            return isEqual(lhs, rhs)
        }
    }
    
    public init<T: Equatable>(_ base: T) {
        self.init(base, isEqual: ==)
    }
    
    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.isEqual(lhs.base, rhs.base)
    }
}
