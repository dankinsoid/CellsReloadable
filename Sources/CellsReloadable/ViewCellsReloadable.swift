import SwiftUI

public protocol ViewCellsReloadable {

    func reload(
        cells: LazyArray<ViewCell>,
        completion: (() -> Void)?
    )
}

public extension ViewCellsReloadable {

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - cells: The cells to use for reloading.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload(
        @ViewCellsBuilder cells: () -> LazyArray<ViewCell>,
        map: @escaping (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(cells: cells().map(map), completion: completion)
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The collection of ```ViewCellConvertible``` items.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection>(with cells: Data, completion: (() -> Void)? = nil) where Data.Element: ViewCellConvertible {
        reload(
            cells: (cells as? LazyArray<ViewCell>) ?? LazyArray(cells).map(\.asViewCell),
            completion: completion
        )
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The unidentified data used for reloading, with item indices serving as IDs.
    ///   - create: The block to create the cell view for each data item.
    ///   - render: The block to render the cell view with data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection, Cell: UIView>(
        with data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        map: @escaping (ViewCell, Data.Element) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) {
        reload(
            cells: LazyArray(data).map { data in
                map(
                    ViewCell {
                        create(data)
                    } render: {
                        render($0, data)
                    },
                    data
                )
            },
            completion: completion
        )
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The data to use for reloading.
    ///   - id: The block to get the identifier for each data item.
    ///   - create: The block to create the cell view for each data item.
    ///   - render: The block to render the cell view with data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection, ID: Hashable, Cell: UIView>(
        with data: Data,
        id: @escaping (Data.Element) -> ID,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        map: @escaping (ViewCell, Data.Element) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) {
        reload(
            cells: LazyArray(data).map { data in
                map(
                    ViewCell(id: id(data)) {
                        create(data)
                    } render: {
                        render($0, data)
                    },
                    data
                )
            },
            completion: completion
        )
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The data to use for reloading.
    ///   - create: The block to create the cell view for each data item.
    ///   - render: The block to render the cell view with data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection, ID: Hashable, Cell: UIView>(
        with data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        map: @escaping (ViewCell, Data.Element) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) where Data.Element: Identifiable<ID> {
        reload(
            with: data,
            id: \.id,
            create: create,
            render: render,
            map: map,
            completion: completion
        )
    }
}

public extension ViewCellsReloadable {

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The unidentified data used for reloading, with item indices serving as IDs.
    ///   - create: The block to create the cell view for each data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection>(
        with data: Data,
        @ViewCellsBuilder create: @escaping (Data.Element) -> LazyArray<ViewCell>,
        map: @escaping (ViewCell, Data.Element) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) {
        reload(
            with: data.flatMap { props in
                create(props).map {
                    map($0, props)
                }
            },
            completion: completion
        )
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The data to use for reloading.
    ///   - id: The block to get the identifier for each data item.
    ///   - create: The block to create the cell view for each data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection, ID: Hashable>(
        with data: Data,
        id: @escaping (Data.Element) -> ID,
        @ViewCellsBuilder create: @escaping (Data.Element) -> LazyArray<ViewCell>,
        map: (ViewCell, Data.Element) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) {
        reload(
            with: data,
            create: create,
            map: { cell, props in
                cell.updateIDIfNeeded(id: id(props))
            },
            completion: completion
        )
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The data to use for reloading.
    ///   - create: The block to create the cell view for each data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Data: Collection, ID: Hashable>(
        with data: Data,
        @ViewCellsBuilder create: @escaping (Data.Element) -> LazyArray<ViewCell>,
        map: (ViewCell, Data.Element) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) where Data.Element: Identifiable<ID> {
        reload(
            with: data,
            id: \.id,
            create: create,
            map: map,
            completion: completion
        )
    }
}

public extension ViewCellsReloadable {

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The unidentified data used for reloading, with item indices serving as IDs.
    ///   - create: The block to create the cell view for each data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<Cell: RenderableView>(
        with data: some Collection<Cell.Props>,
        create: @escaping () -> Cell,
        map: @escaping (ViewCell, Cell.Props) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) {
        reload(with: data) { _ in
            create()
        } render: {
            $0.render(with: $1)
        } map: {
            map($0, $1)
        } completion: {
            completion?()
        }
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The data to use for reloading.
    ///   - id: The block to get the identifier for each data item.
    ///   - create: The block to create the cell view for each data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<ID: Hashable, Cell: RenderableView>(
        with data: some Collection<Cell.Props>,
        id: @escaping (Cell.Props) -> ID,
        create: @escaping () -> Cell,
        map: @escaping (ViewCell, Cell.Props) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) {
        reload(with: data, id: id) { _ in
            create()
        } render: {
            $0.render(with: $1)
        } map: {
            map($0, $1)
        } completion: {
            completion?()
        }
    }

    /// Reloads the collection view with the specified cells.
    ///
    /// - Parameters:
    ///   - data: The data to use for reloading.
    ///   - create: The block to create the cell view for each data item.
    ///   - map: The block to add values to each cell.
    ///   - completion: The block to execute after the reload operation completes.
    func reload<ID: Hashable, Cell: RenderableView>(
        with data: some Collection<Cell.Props>,
        create: @escaping () -> Cell,
        map: @escaping (ViewCell, Cell.Props) -> ViewCell = { cell, _ in cell },
        completion: (() -> Void)? = nil
    ) where Cell.Props: Identifiable<ID> {
        reload(with: data) { _ in
            create()
        } render: {
            $0.render(with: $1)
        } map: {
            map($0, $1)
        } completion: {
            completion?()
        }
    }
}
