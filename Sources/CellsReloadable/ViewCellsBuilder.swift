import SwiftUI

@resultBuilder
public enum ViewCellsBuilder {

    public static func buildBlock(_ components: LazyArray<ViewCell>...) -> LazyArray<ViewCell> {
        LazyArray(components.joined())
    }

    @inlinable
    public static func buildArray(_ components: [LazyArray<ViewCell>]) -> LazyArray<ViewCell> {
        LazyArray(components.joined())
    }

    @inlinable
    public static func buildEither(first component: LazyArray<ViewCell>) -> LazyArray<ViewCell> {
        component
    }

    @inlinable
    public static func buildEither(second component: LazyArray<ViewCell>) -> LazyArray<ViewCell> {
        component
    }

    @inlinable
    public static func buildOptional(_ component: LazyArray<ViewCell>?) -> LazyArray<ViewCell> {
        component ?? []
    }

    @inlinable
    public static func buildLimitedAvailability(_ component: LazyArray<ViewCell>) -> LazyArray<ViewCell> {
        component
    }

    @inlinable
    public static func buildExpression<Cell: ViewCellConvertible>(
        _ expression: Cell,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> LazyArray<ViewCell> {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }

    @inlinable
    public static func buildExpression(
        _ expression: any ViewCellConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> LazyArray<ViewCell> {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }

    @inlinable
    public static func buildExpression<T: View>(_ expression: T, fileID: String = #fileID, line: UInt = #line, column: UInt = #column) -> LazyArray<ViewCell> {
        buildExpression(
            ViewCell(id: CodeID(fileID: fileID, line: line, column: column)) {
                expression
            }
        )
    }

    @inlinable
    public static func buildExpression<C: Collection>(_ expression: C) -> LazyArray<ViewCell> where C.Element: ViewCellConvertible {
        (expression as? LazyArray<ViewCell>) ?? LazyArray(expression).map(\.asViewCell)
    }

    @inlinable
    public static func buildExpression<C: Collection>(_ expression: C) -> LazyArray<ViewCell> where C.Element == any ViewCellConvertible {
        LazyArray(expression).map(\.asViewCell)
    }
}
