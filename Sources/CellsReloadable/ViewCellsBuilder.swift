import SwiftUI

@resultBuilder
public enum ViewCellsBuilder {

    public static func buildBlock(_ components: [ViewCell]...) -> [ViewCell] {
        Array(components.joined())
    }

    @inlinable
    public static func buildArray(_ components: [[ViewCell]]) -> [ViewCell] {
        Array(components.joined())
    }

    @inlinable
    public static func buildEither(first component: [ViewCell]) -> [ViewCell] {
        component
    }

    @inlinable
    public static func buildEither(second component: [ViewCell]) -> [ViewCell] {
        component
    }

    @inlinable
    public static func buildOptional(_ component: [ViewCell]?) -> [ViewCell] {
        component ?? []
    }

    @inlinable
    public static func buildLimitedAvailability(_ component: [ViewCell]) -> [ViewCell] {
        component
    }

    @inlinable
    public static func buildExpression<Cell: ViewCellConvertible>(
        _ expression: Cell,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> [ViewCell] {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }

    @inlinable
    public static func buildExpression(
        _ expression: any ViewCellConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> [ViewCell] {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }

    @inlinable
    public static func buildExpression<T: View>(_ expression: T, fileID: String = #fileID, line: UInt = #line, column: UInt = #column) -> [ViewCell] {
        buildExpression(
            ViewCell(id: CodeID(fileID: fileID, line: line, column: column)) {
                expression
            }
        )
    }

    @inlinable
    public static func buildExpression<C: Sequence>(_ expression: C) -> [ViewCell] where C.Element: ViewCellConvertible {
        (expression as? [ViewCell]) ?? expression.map(\.asViewCell)
    }

    @inlinable
    public static func buildExpression<C: Sequence>(_ expression: C) -> [ViewCell] where C.Element == any ViewCellConvertible {
        expression.map(\.asViewCell)
    }
}
