import SwiftUI

@resultBuilder
public enum SingleViewCellBuilder {

    public static func buildBlock(_ component: ViewCell) -> ViewCell {
        component
    }

    @inlinable
    public static func buildEither(first component: ViewCell) -> ViewCell {
        component
    }

    @inlinable
    public static func buildEither(second component: ViewCell) -> ViewCell {
        component
    }

    @inlinable
    public static func buildLimitedAvailability(_ component: ViewCell) -> ViewCell {
        component
    }

    @inlinable
    public static func buildExpression(
        _ expression: some ViewCellConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> ViewCell {
        expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))
    }

    @inlinable
    public static func buildExpression(
        _ expression: any ViewCellConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> ViewCell {
        expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))
    }

    @inlinable
    public static func buildExpression<V: UIView>(
        _ expression: @escaping @autoclosure () -> V,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> ViewCell {
        ViewCell(id: CodeID(fileID: fileID, line: line, column: column)) {
            expression()
        } render: { _ in
        }
    }

    @inlinable
    public static func buildExpression<T: View>(_ expression: T, fileID: String = #fileID, line: UInt = #line, column: UInt = #column) -> ViewCell {
        buildExpression(
            ViewCell(id: CodeID(fileID: fileID, line: line, column: column)) {
                expression
            }
        )
    }
}
