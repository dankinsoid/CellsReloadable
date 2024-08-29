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
    public static func buildExpression(
        _ expression: some CellsSectionConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> [CellsSection] {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }

    @inlinable
    public static func buildExpression(
        _ expression: any CellsSectionConvertible,
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column
    ) -> [CellsSection] {
        [expression.updateIDIfNeeded(id: CodeID(fileID: fileID, line: line, column: column))]
    }
}
