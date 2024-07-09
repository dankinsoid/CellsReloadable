import SwiftUI

@resultBuilder
public enum CellsSectionsBuilder {

    public static func buildBlock(_ components: LazyArray<CellsSection>...) -> LazyArray<CellsSection> {
        LazyArray(components.joined())
    }

    @inlinable
    public static func buildArray(_ components: [LazyArray<CellsSection>]) -> LazyArray<CellsSection> {
        LazyArray(components.joined())
    }

    @inlinable
    public static func buildEither(first component: LazyArray<CellsSection>) -> LazyArray<CellsSection> {
        component
    }

    @inlinable
    public static func buildEither(second component: LazyArray<CellsSection>) -> LazyArray<CellsSection> {
        component
    }

    @inlinable
    public static func buildOptional(_ component: LazyArray<CellsSection>?) -> LazyArray<CellsSection> {
        component ?? []
    }

    @inlinable
    public static func buildLimitedAvailability(_ component: LazyArray<CellsSection>) -> LazyArray<CellsSection> {
        component
    }

    @inlinable
    public static func buildExpression(
        _ expression: some CellsSectionConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> LazyArray<CellsSection> {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }

    @inlinable
    public static func buildExpression(
        _ expression: any CellsSectionConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> LazyArray<CellsSection> {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }
}
