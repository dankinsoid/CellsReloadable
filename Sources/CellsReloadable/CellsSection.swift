import SwiftUI

public struct CellsSection: Identifiable {

    public var id: AnyHashable { values.id }
    public var values: CellsSection.Values
    public let cells: [ViewCell]

    public init(
        values: CellsSection.Values,
        cells: [ViewCell]
    ) {
        self.values = values
        self.cells = cells
    }

    public struct Values: Identifiable {

        public var id: AnyHashable
        private var values: [PartialKeyPath<Self>: Any] = [:]

        public init(id: AnyHashable) {
            self.id = id
        }

        public subscript<V>(_ keyPath: WritableKeyPath<CellsSection.Values, V>) -> V? {
            get { values[keyPath] as? V }
            set { values[keyPath] = newValue }
        }
    }
}

public extension CellsSection {

    init(
        id: AnyHashable = NoneID(),
        @ViewCellsBuilder _ cells: () -> [ViewCell]
    ) {
        self.init(id: id, cells: cells())
    }

    init<Data: Collection>(
        id: AnyHashable = NoneID(),
        cells: Data
    ) where Data.Element: ViewCellConvertible {
        self.init(
            values: Values(id: id),
            cells: (cells as? [ViewCell]) ?? cells.map(\.asViewCell)
        )
    }

    init<Data: Collection, Cell: UIView>(
        id: AnyHashable = NoneID(),
        data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void
    ) {
        self.init(
            values: Values(id: id),
            cells: data.map { data in
                ViewCell {
                    create(data)
                } render: {
                    render($0, data)
                }
            }
        )
    }

    init<Data: Collection, Cell: UIView, ID: Hashable>(
        id: AnyHashable = NoneID(),
        data: Data,
        cellID: (Data.Element) -> ID,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void
    ) {
        self.init(
            values: Values(id: id),
            cells: data.map { data in
                ViewCell(id: cellID(data)) {
                    create(data)
                } render: {
                    render($0, data)
                }
            }
        )
    }

    init<Data: Collection, ID: Hashable, Cell: UIView>(
        id: AnyHashable = NoneID(),
        data: Data,
        create: @escaping (Data.Element) -> Cell,
        render: @escaping (Cell, Data.Element) -> Void
    ) where Data.Element: Identifiable<ID> {
        self.init(
            id: id,
            data: data,
            cellID: \.id,
            create: create,
            render: render
        )
    }
}

public extension CellsSection {

    init<Data: Collection>(
        id: AnyHashable = NoneID(),
        data: Data,
        @ViewCellsBuilder create: @escaping (Data.Element) -> [ViewCell]
    ) {
        self.init(
            id: id,
            cells: data.flatMap(create)
        )
    }

    init<Data: Collection, ID: Hashable>(
        id: AnyHashable = NoneID(),
        data: Data,
        cellID: (Data.Element) -> ID,
        @ViewCellsBuilder create: @escaping (Data.Element) -> [ViewCell]
    ) {
        self.init(
            id: id,
            cells: data.flatMap { props in
                create(props).map {
                    $0.updateIDIfNeeded(id: cellID(props))
                }
            }
        )
    }

    init<Data: Collection, ID: Hashable>(
        id: AnyHashable = NoneID(),
        data: Data,
        @ViewCellsBuilder create: @escaping (Data.Element) -> [ViewCell]
    ) where Data.Element: Identifiable<ID> {
        self.init(
            id: id,
            data: data,
            cellID: \.id,
            create: create
        )
    }
}

public extension CellsSection {

    init<Cell: RenderableView, ID: Hashable>(
        id: AnyHashable = NoneID(),
        data: some Collection<Cell.Props>,
        cellID: (Cell.Props) -> ID,
        create: @escaping () -> Cell
    ) {
        self.init(
            id: id,
            data: data,
            cellID: cellID
        ) { _ in
            create()
        } render: {
            $0.render(with: $1)
        }
    }

    init<ID: Hashable, Cell: RenderableView>(
        id: AnyHashable = NoneID(),
        data: some Collection<Cell.Props>,
        create: @escaping () -> Cell
    ) where Cell.Props: Identifiable<ID> {
        self.init(
            id: id,
            data: data
        ) { _ in
            create()
        } render: {
            $0.render(with: $1)
        }
    }

    init<Cell: RenderableView>(
        id: AnyHashable = NoneID(),
        data: some Collection<Cell.Props>,
        create: @escaping () -> Cell
    ) {
        self.init(
            id: id,
            data: data
        ) { _ in
            create()
        } render: {
            $0.render(with: $1)
        }
    }
}

public protocol CellsSectionConvertible {

    var asCellsSection: CellsSection { get }
}

extension CellsSection: CellsSectionConvertible {

    public var asCellsSection: CellsSection { self }
}

public extension CellsSectionConvertible {

    func with<V>(_ keyPath: WritableKeyPath<CellsSection.Values, V>, _ value: V) -> CellsSection {
        var section = asCellsSection
        section.values[keyPath: keyPath] = value
        return section
    }
    
    func map(_ transform: (ViewCell) -> ViewCell) -> CellsSection {
        let section = asCellsSection
        return CellsSection(values: section.values, cells: section.cells.map(transform))
    }

    func updateIDIfNeeded(id: AnyHashable) -> CellsSection {
        var result = asCellsSection
        if result.id.base is NoneID {
            result.values.id = id
        }
        return result
    }
}
