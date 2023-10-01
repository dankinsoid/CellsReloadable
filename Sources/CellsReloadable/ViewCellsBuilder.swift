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
    public static func buildExpression<Cell: ViewCellConvertible>(_ expression: Cell) -> [ViewCell] {
        [expression.asViewCell]
    }

    @inlinable
    public static func buildExpression<T: View>(_ expression: T, file: String = #fileID, line: UInt = #line, column: UInt = #column) -> [ViewCell] {
        buildExpression(
            ViewCell(fileID: file, line: line, column: column) {
                expression
            }
        )
    }

    @inlinable
    public static func buildExpression<C: Sequence>(_ expression: C) -> [ViewCell] where C.Element: ViewCellConvertible {
        expression.map(\.asViewCell)
    }
}
