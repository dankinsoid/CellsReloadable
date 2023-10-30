import UIKit

public struct LayoutContext {
    
    public var localID: AnyHashable
    public var environments: ()
    public var subviews: LayoutSubviews
    
    public init(
        localID: AnyHashable,
        subviews: LayoutSubviews,
        environments: () = ()
    ) {
        self.localID = localID
        self.subviews = subviews
        self.environments = environments
    }
    
    public func withID(_ id: (AnyHashable) -> AnyHashable) -> LayoutContext {
        with(id: id(localID))
    }
    
    public func union(id: some Hashable) -> LayoutContext {
        withID {
            UnionID($0, id)
        }
    }
    
    public func with(id: some Hashable) -> LayoutContext {
        var result = self
        result.localID = id
        return result
    }
}
