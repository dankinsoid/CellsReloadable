import SwiftUI

public protocol ViewCellsReloadable {

    func reload(
        cells: [ViewCell],
        completion: (() -> Void)?
    )
}

public extension ViewCellsReloadable {

    func reload(
        @ViewCellsBuilder _ cells: () -> [ViewCell],
        completion: (() -> Void)?
    ) {
        reload(cells: cells(), completion: completion)
    }

    func reload<Data: Collection, Cell: UIView>(
        data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        completion: (() -> Void)? = nil
    ) {
        reload(
            cells: data.enumerated().map { index, data in
                ViewCell(id: "\(index)") {
                    create(data)
                } render: {
                    render($0, data)
                }
            },
            completion: completion
        )
    }

    func reload<Data: Collection, ID: CustomStringConvertible, Cell: UIView>(
        data: Data,
        id: (Data.Element) -> ID,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        completion: (() -> Void)? = nil
    ) {
        reload(
            cells: data.map { data in
                ViewCell(id: id(data).description) {
                    create(data)
                } render: {
                    render($0, data)
                }
            },
            completion: completion
        )
    }

    func reload<Data: Collection, ID: Hashable & CustomStringConvertible, Cell: UIView>(
        data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void,
        completion: (() -> Void)? = nil
    ) where Data.Element: Identifiable<ID> {
        reload(
            data: data,
            id: \.id.description,
            create: create,
            render: render,
            completion: completion
        )
    }
}

public extension ViewCellsReloadable {

    func reload<Data: Collection, Cell: View>(
        data: Data,
        @ViewBuilder create: @escaping (Data.Element) -> Cell,
        completion: (() -> Void)? = nil
    ) {
        reload(data: data) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        } completion: {
            completion?()
        }
    }

    func reload<Data: Collection, ID: CustomStringConvertible, Cell: View>(
        data: Data,
        id: (Data.Element) -> ID,
        @ViewBuilder create: @escaping (Data.Element) -> Cell,
        completion: (() -> Void)? = nil
    ) {
        reload(data: data, id: id) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        } completion: {
            completion?()
        }
    }

    func reload<Data: Collection, ID: Hashable & CustomStringConvertible, Cell: View>(
        data: Data,
        @ViewBuilder create: @escaping (Data.Element) -> Cell,
        completion: (() -> Void)? = nil
    ) where Data.Element: Identifiable<ID> {
        reload(data: data) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        } completion: {
            completion?()
        }
    }
}

public extension ViewCellsReloadable {

    func reload<Cell: RenderableView>(
        data: some Collection<Cell.Props>,
        create: @escaping (Cell.Props) -> Cell,
        completion: (() -> Void)? = nil
    ) {
        reload(data: data) {
            create($0)
        } render: {
            $0.render(with: $1)
        } completion: {
            completion?()
        }
    }

    func reload<ID: CustomStringConvertible, Cell: RenderableView>(
        data: some Collection<Cell.Props>,
        id: (Cell.Props) -> ID,
        create: @escaping (Cell.Props) -> Cell,
        completion: (() -> Void)? = nil
    ) {
        reload(data: data, id: id) {
            create($0)
        } render: {
            $0.render(with: $1)
        } completion: {
            completion?()
        }
    }

    func reload<ID: Hashable & CustomStringConvertible, Cell: RenderableView>(
        data: some Collection<Cell.Props>,
        create: @escaping (Cell.Props) -> Cell,
        completion: (() -> Void)? = nil
    ) where Cell.Props: Identifiable<ID> {
        reload(data: data) {
            create($0)
        } render: {
            $0.render(with: $1)
        } completion: {
            completion?()
        }
    }
}
