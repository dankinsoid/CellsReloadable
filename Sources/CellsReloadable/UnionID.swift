import Foundation

public struct UnionID<F: Hashable, S: Hashable>: Hashable {

    public var first: F
    public var second: S

    public init(_ first: F, _ second: S) {
        self.first = first
        self.second = second
    }
}
