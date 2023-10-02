import SwiftUI

public protocol ViewCellsReloadable {

    func reload(
        cells: [ViewCell],
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
        @ViewCellsBuilder cells: () -> [ViewCell],
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(cells: cells().map(map), completion: completion)
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
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(
            cells: data.enumerated().map { index, data in
                map(
                    ViewCell(id: "\(index)") {
                        create(data)
                    } render: {
                        render($0, data)
                    }
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
    func reload<Data: Collection, ID: CustomStringConvertible, Cell: UIView>(
        with data: Data,
        id: (Data.Element) -> ID,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(
            cells: data.map { data in
                map(
                    ViewCell(id: id(data).description) {
                        create(data)
                    } render: {
                        render($0, data)
                    }
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
    func reload<Data: Collection, ID: Hashable & CustomStringConvertible, Cell: UIView>(
        with data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) where Data.Element: Identifiable<ID> {
        reload(
            with: data,
            id: \.id.description,
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
    func reload<Data: Collection, Cell: View>(
        with data: Data,
        @ViewBuilder create: @escaping (Data.Element) -> Cell,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(with: data) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        } map: {
            map($0)
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
    func reload<Data: Collection, ID: CustomStringConvertible, Cell: View>(
        with data: Data,
        id: (Data.Element) -> ID,
        @ViewBuilder create: @escaping (Data.Element) -> Cell,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(with: data, id: id) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        } map: {
            map($0)
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
    func reload<Data: Collection, ID: Hashable & CustomStringConvertible, Cell: View>(
        with data: Data,
        @ViewBuilder create: @escaping (Data.Element) -> Cell,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) where Data.Element: Identifiable<ID> {
        reload(with: data) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        } map: {
            map($0)
        } completion: {
            completion?()
        }
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
        create: @escaping (Cell.Props) -> Cell,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(with: data) {
            create($0)
        } render: {
            $0.render(with: $1)
        } map: {
            map($0)
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
    func reload<ID: CustomStringConvertible, Cell: RenderableView>(
        with data: some Collection<Cell.Props>,
        id: (Cell.Props) -> ID,
        create: @escaping (Cell.Props) -> Cell,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) {
        reload(with: data, id: id) {
            create($0)
        } render: {
            $0.render(with: $1)
        } map: {
            map($0)
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
    func reload<ID: Hashable & CustomStringConvertible, Cell: RenderableView>(
        with data: some Collection<Cell.Props>,
        create: @escaping (Cell.Props) -> Cell,
        map: (ViewCell) -> ViewCell = { $0 },
        completion: (() -> Void)? = nil
    ) where Cell.Props: Identifiable<ID> {
        reload(with: data) {
            create($0)
        } render: {
            $0.render(with: $1)
        } map: {
            map($0)
        } completion: {
            completion?()
        }
    }
}
