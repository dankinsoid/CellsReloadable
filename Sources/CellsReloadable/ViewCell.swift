import SwiftUI

public struct ViewCell: Identifiable {

    private let create: () -> UIView
    private let render: (UIView) -> Void
    public let id: String
    public var values: Values
    public let type: Any.Type

    public var typeIdentifier: String {
        String(reflecting: type)
    }

    public init<Cell: UIView>(
        id: String,
        create: @escaping () -> Cell,
        render: @escaping (Cell) -> Void = { _ in }
    ) {
        self.init(
            id: id,
            type: Cell.self
        ) {
            create()
        } render: { view in
            guard let cell = view as? Cell else {
                return
            }
            render(cell)
        }
    }

    @_disfavoredOverload
    public init<Cell: UIView>(
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column,
        create: @escaping () -> Cell,
        render: @escaping (Cell) -> Void = { _ in }
    ) {
        self.init(
            id: .codeID(fileID: fileID, line: line, column: column),
            type: Cell.self
        ) {
            create()
        } render: { view in
            guard let cell = view as? Cell else {
                return
            }
            render(cell)
        }
    }

    public init(
        id: String,
        values: ViewCell.Values = ViewCell.Values(),
        type: Any.Type,
        create: @escaping () -> UIView,
        render: @escaping (UIView) -> Void
    ) {
        self.id = id
        self.create = create
        self.render = render
        self.values = values
        self.type = type
    }

    public func createView() -> UIView {
        create()
    }

    public func reloadView(_ view: UIView) {
        render(view)
    }

    public struct Values {

        private var values: [PartialKeyPath<Self>: Any] = [:]

        public init() {}

        public subscript<V>(_ keyPath: KeyPath<ViewCell.Values, V>) -> V? {
            get { values[keyPath] as? V }
            set { values[keyPath] = newValue }
        }
    }

    public func with<V>(_ keyPath: WritableKeyPath<ViewCell.Values, V>, _ value: V) -> ViewCell {
        var cell = self
        cell.values[keyPath: keyPath] = value
        return cell
    }

    @_disfavoredOverload
    public func with<V>(_ keyPath: KeyPath<ViewCell.Values, V>, _ value: V) -> ViewCell {
        var cell = self
        cell.values[keyPath] = value
        return cell
    }
}

public extension ViewCell {

    init<Cell: View>(
        id: String,
        @ViewBuilder view: () -> Cell
    ) {
        let view = view()
        self.init(
            id: id,
            create: { HostingView(view) },
            render: { $0.rootView = view }
        )
    }

    @_disfavoredOverload
    init<Cell: View>(
        fileID: String = #fileID,
        line: UInt = #line,
        column: UInt = #column,
        @ViewBuilder view: () -> Cell
    ) {
        let view = view()
        self.init(
            id: .codeID(fileID: fileID, line: line, column: column),
            create: { HostingView(view) },
            render: { $0.rootView = view }
        )
    }
}

public extension ViewCell {

    init<Cell: RenderableView>(
        id: String,
        props: Cell.Props,
        create: @escaping () -> Cell
    ) {
        self.init(
            id: id,
            create: create,
            render: { $0.render(with: props) }
        )
    }

    init<Cell: RenderableView>(
        props: Cell.Props,
        create: @escaping () -> Cell
    ) where Cell.Props: Identifiable, Cell.Props.ID: CustomStringConvertible {
        self.init(
            id: props.id.description,
            props: props,
            create: create
        )
    }
}

extension ViewCell: ViewCellConvertible {

    public var asViewCell: ViewCell { self }
}

public protocol ViewCellConvertible {

    var asViewCell: ViewCell { get }
}
