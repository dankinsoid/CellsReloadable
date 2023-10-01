import SwiftUI

public struct CellsSection: Identifiable {

    public var id: String { values.id }
    public var values: CellsSection.Values
    public let cells: [ViewCell]

    public init(
        values: CellsSection.Values,
        cells: [ViewCell]
    ) {
        self.values = values
        self.cells = cells
    }

    public init(
        id: String,
        cells: [ViewCell]
    ) {
        self.init(values: CellsSection.Values(id: id), cells: cells)
    }

    public struct Values: Identifiable {

        public var id: String
        private var values: [PartialKeyPath<Self>: Any] = [:]

        public init(id: String) {
            self.id = id
        }

        public subscript<V>(_ keyPath: KeyPath<CellsSection.Values, V>) -> V? {
            get { values[keyPath] as? V }
            set { values[keyPath] = newValue }
        }
    }

    public func with<V>(_ keyPath: WritableKeyPath<CellsSection.Values, V>, _ value: V) -> CellsSection {
        var section = self
        section.values[keyPath: keyPath] = value
        return section
    }

    @_disfavoredOverload
    public func with<V>(_ keyPath: KeyPath<CellsSection.Values, V>, _ value: V) -> CellsSection {
        var section = self
        section.values[keyPath] = value
        return section
    }

    public func cellsWith<V>(_ keyPath: KeyPath<ViewCell.Values, V>, _ value: V) -> CellsSection {
        CellsSection(values: values, cells: cells.map { $0.with(keyPath, value) })
    }

    @_disfavoredOverload
    public func cellsWith<V>(_ keyPath: WritableKeyPath<ViewCell.Values, V>, _ value: V) -> CellsSection {
        CellsSection(values: values, cells: cells.map { $0.with(keyPath, value) })
    }
}

public extension CellsSection {

    init(
        id: String,
        @ViewCellsBuilder _ cells: () -> [ViewCell]
    ) {
        self.init(id: id, cells: cells())
    }

    init(
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column,
        @ViewCellsBuilder _ cells: () -> [ViewCell]
    ) {
        self.init(id: .codeID(fileID: fileID, line: line, column: column), cells: cells())
    }

    init<Data: Collection, Cell: UIView>(
        id: String,
        data: Data,
        cellID: (Data.Element) -> String,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void
    ) {
        self.init(
            id: id,
            cells: data.map { data in
                ViewCell(id: cellID(data)) {
                    create(data)
                } render: {
                    render($0, data)
                }
            }
        )
    }

    init<Data: Collection, ID: CustomStringConvertible, Cell: UIView>(
        id: String,
        data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void
    ) where Data.Element: Identifiable<ID> {
        self.init(
            id: id,
            data: data,
            cellID: \.id.description,
            create: create,
            render: render
        )
    }

    init<Data: Collection, Cell: UIView>(
        id: String,
        data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void
    ) {
        self.init(
            id: id,
            cells: data.enumerated().map { index, data in
                ViewCell(id: "\(index)") {
                    create(data)
                } render: {
                    render($0, data)
                }
            }
        )
    }
}

public extension CellsSection {

    init<Data: Collection, Cell: View>(
        id: String,
        data: Data,
        cellID: (Data.Element) -> String,
        @ViewBuilder create: @escaping (Data.Element) -> Cell
    ) {
        self.init(
            id: id,
            data: data,
            cellID: cellID
        ) {
            HostingView(create($0))
        } render: {
            ($0 as HostingView<Cell>).rootView = create($1)
        }
    }

    init<Data: Collection, ID: CustomStringConvertible, Cell: View>(
        id: String,
        data: Data,
        @ViewBuilder create: @escaping (Data.Element) -> Cell
    ) where Data.Element: Identifiable<ID> {
        self.init(
            id: id,
            data: data
        ) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        }
    }

    init<Data: Collection, Cell: View>(
        id: String,
        data: Data,
        @ViewBuilder create: @escaping (Data.Element) -> Cell
    ) {
        self.init(
            id: id,
            data: data
        ) {
            HostingView(create($0))
        } render: {
            $0.rootView = create($1)
        }
    }
}

public extension CellsSection {

    init<Cell: RenderableView>(
        id: String,
        data: some Collection<Cell.Props>,
        cellID: (Cell.Props) -> String,
        create: @escaping (Cell.Props) -> Cell
    ) {
        self.init(
            id: id,
            data: data,
            cellID: cellID
        ) {
            create($0)
        } render: {
            $0.render(with: $1)
        }
    }

    init<ID: CustomStringConvertible, Cell: RenderableView>(
        id: String,
        data: some Collection<Cell.Props>,
        create: @escaping (Cell.Props) -> Cell
    ) where Cell.Props: Identifiable<ID> {
        self.init(
            id: id,
            data: data
        ) {
            create($0)
        } render: {
            $0.render(with: $1)
        }
    }

    init<Cell: RenderableView>(
        id: String,
        data: some Collection<Cell.Props>,
        create: @escaping (Cell.Props) -> Cell
    ) {
        self.init(
            id: id,
            data: data
        ) {
            create($0)
        } render: {
            $0.render(with: $1)
        }
    }
}

extension CellsSection: CellsSectionConvertible {

    public var asCellsSection: CellsSection { self }
}

public protocol CellsSectionConvertible {

    var asCellsSection: CellsSection { get }
}
