import Foundation

public protocol CellsSectionsReloadable: ViewCellsReloadable {

    func reload(
        sections: LazyArray<CellsSection>,
        completion: (() -> Void)?
    )
}

public extension ViewCellsReloadable where Self: CellsSectionsReloadable {

    func reload(cells: LazyArray<ViewCell>, completion: (() -> Void)?) {
        reload(sections: [CellsSection(id: 0, cells: cells)], completion: completion)
    }
}

public extension CellsSectionsReloadable {

    func reload(
        @CellsSectionsBuilder _ sections: () -> [CellsSection],
        completion: (() -> Void)? = nil
    ) {
        reload(sections: LazyArray(sections()), completion: completion)
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The collection of ```CellsSectionConvertible``` items.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection>(
        sections data: Data,
        completion: (() -> Void)? = nil
    ) where Data.Element: CellsSectionConvertible {
        reload(
            sections: (data as? LazyArray<CellsSection>) ?? LazyArray(data).map(\.asCellsSection),
            completion: completion
        )
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The collection of ```CellsSectionConvertible``` items.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection>(
        sections data: Data,
        completion: (() -> Void)? = nil
    ) where Data.Element == CellsSectionConvertible {
        reload(sections: LazyArray(data).map(\.asCellsSection), completion: completion)
    }
}
