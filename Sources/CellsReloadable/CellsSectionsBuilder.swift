import SwiftUI

@resultBuilder
public enum CellsSectionsBuilder {

    public static func buildBlock(_ components: [CellsSection]...) -> [CellsSection] {
        Array(components.joined())
    }

    @inlinable
    public static func buildArray(_ components: [[CellsSection]]) -> [CellsSection] {
        Array(components.joined())
    }

    @inlinable
    public static func buildEither(first component: [CellsSection]) -> [CellsSection] {
        component
    }

    @inlinable
    public static func buildEither(second component: [CellsSection]) -> [CellsSection] {
        component
    }

    @inlinable
    public static func buildOptional(_ component: [CellsSection]?) -> [CellsSection] {
        component ?? []
    }

    @inlinable
    public static func buildLimitedAvailability(_ component: [CellsSection]) -> [CellsSection] {
        component
    }

    @inlinable
    public static func buildExpression(_ expression: some CellsSectionConvertible) -> [CellsSection] {
        [expression.asCellsSection]
    }

    @inlinable
    public static func buildExpression<C: Sequence>(_ expression: C) -> [CellsSection] where C.Element: CellsSectionConvertible {
        expression.map(\.asCellsSection)
    }

    @inlinable
    public static func buildExpression<C: Sequence>(
        _ expression: C,
        file: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> [CellsSection] where C.Element: ViewCellConvertible {
        buildExpression(
            CellsSection(
                fileID: file,
                line: line,
                column: column
            ) {
                expression
            }
        )
    }
}
