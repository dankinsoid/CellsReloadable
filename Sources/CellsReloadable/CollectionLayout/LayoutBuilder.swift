import Foundation

@resultBuilder
public enum LayoutBuilder {
    
    public static func buildBlock() -> some CollectionLayout {
        EmptyLayout()
    }
    
    public static func buildPartialBlock(first: some CollectionLayout) -> some CollectionLayout {
        first
    }
    
    public static func buildPartialBlock(accumulated: some CollectionLayout, next: some CollectionLayout) -> some CollectionLayout {
        PairLayout(l: accumulated, r: next)
    }
    
    public static func buildEither<F: CollectionLayout, S: CollectionLayout>(first component: F) -> some CollectionLayout {
        IfLayout<F, S>.first(component.layout)
    }
    
    public static func buildEither<F: CollectionLayout, S: CollectionLayout>(second component: S) -> some CollectionLayout {
        IfLayout<F, S>.second(component.layout)
    }
    
    @inlinable
    public static func buildOptional<L: CollectionLayout>(_ component: L?) -> some CollectionLayout {
        component
    }
    
    @inlinable
    public static func buildLimitedAvailability(_ component: some CollectionLayout) -> some CollectionLayout {
        component
    }
    
    @inlinable
    public static func buildExpression(_ expression: some CollectionLayout) -> some CollectionLayout {
        expression
    }
}
