import UIKit

public protocol CollectionLayout {
    
    associatedtype Body: CollectionLayout
    associatedtype Layout: CustomCollectionLayout = Body.Layout
    
    @LayoutBuilder
    var body: Body { get }
    var layout: Self.Layout { get }
}

extension CollectionLayout where Layout == Body.Layout {
    
    public var layout: Body.Layout {
        body.layout
    }
}

extension CollectionLayout where Layout == Self {
    
    public var layout: Self {
        self
    }
}

public protocol CustomCollectionLayout: CollectionLayout where Layout == Self {

    associatedtype Cache = Void

    var properties: LayoutProperties { get }

    func createCache() -> Cache

    func sizeThatFits(
        proposal size: ProposedSize,
        context: LayoutContext,
        cache: inout Cache
    ) -> ProposedSize

    func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Cache,
        place: (ViewCell, CGRect) -> Void
    )
    
    func makeItems(localID: some Hashable) -> [ViewCell]
    func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout]
}

extension CustomCollectionLayout {

    public var properties: LayoutProperties { LayoutProperties() }
}

extension CustomCollectionLayout where Cache == Void {
    
    public func createCache() -> Void {
    }
}

extension CollectionLayout where Body == Never, Self: CustomCollectionLayout {
    
    /// A non-existent body.
    ///
    /// > Warning: Do not invoke this property directly. It will trigger a fatal error at runtime.
    @_transparent
    public var body: Body {
        fatalError(
      """
      '\(Self.self)' has no body. …
      
      Do not access a reducer's 'body' property directly, as it may not exist.
      """
        )
    }
}

extension Never: CollectionLayout {
    
    public struct Layout: CustomCollectionLayout {
        
        public typealias Layout = Never.Layout
        public typealias Body = Never
        
        public func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout ()) -> ProposedSize {
            .zero
        }
    
        public func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout (), place: (ViewCell, CGRect) -> Void) {
        }
        
        public func makeItems(localID: some Hashable) -> [ViewCell] {
            []
        }
        
        public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
            []
        }
        
        public var layout: Never.Layout {
            self
        }
    }
    
    public var layout: Layout {
        Layout()
    }
}
