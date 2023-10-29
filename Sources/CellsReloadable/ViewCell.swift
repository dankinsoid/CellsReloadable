import SwiftUI

public struct ViewCell: Identifiable {

    private let create: () -> UIView
    private let render: (UIView) -> Void
    public var id: AnyHashable
    public var values: Values
    public let type: Any.Type

    public var typeIdentifier: String {
        String(reflecting: type)
    }

    public init(
        id: AnyHashable,
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

        public subscript<V>(_ keyPath: WritableKeyPath<ViewCell.Values, V>) -> V? {
            get { values[keyPath] as? V }
            set { values[keyPath] = newValue }
        }
    }
}

public extension ViewCell {

    init<Cell: UIView>(
        id: AnyHashable = NoneID(),
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

    init<Cell: UIView>(
        id: AnyHashable = NoneID(),
        _ create: @escaping @autoclosure () -> Cell,
        render: @escaping (Cell) -> Void = { _ in }
    ) {
        self.init(
            id: id,
            create: create,
            render: render
        )
    }
}

public extension ViewCell {

    init<Cell: View>(
        id: AnyHashable = NoneID(),
        @ViewBuilder view: () -> Cell
    ) {
        self.init(id: id, view())
    }

    init<Cell: View>(
        id: AnyHashable = NoneID(),
        _ view: Cell
    ) {
        self.init(id: id) {
            HostingView(view)
        } render: {
            $0.rootView = view
        }
    }
}

public extension ViewCell {

    @_disfavoredOverload
    init<Cell: RenderableView>(
        id: AnyHashable = NoneID(),
        with props: Cell.Props,
        create: @escaping () -> Cell
    ) {
        self.init(
            id: id,
            create: create
        ) {
            $0.render(with: props)
        }
    }

    init<Cell: RenderableView>(
        with props: Cell.Props,
        create: @escaping () -> Cell
    ) where Cell.Props: Identifiable {
        self.init(
            id: props.id,
            with: props,
            create: create
        )
    }

    @_disfavoredOverload
    init<Cell: RenderableView>(
        id: AnyHashable = NoneID(),
        _ create: @escaping @autoclosure () -> Cell,
        with props: Cell.Props
    ) {
        self.init(
            id: id,
            with: props,
            create: create
        )
    }

    init<Cell: RenderableView>(
        _ create: @escaping @autoclosure () -> Cell,
        with props: Cell.Props
    ) where Cell.Props: Identifiable {
        self.init(
            id: props.id,
            with: props,
            create: create
        )
    }
}

public protocol ViewCellConvertible {

    var asViewCell: ViewCell { get }
}

extension ViewCell: ViewCellConvertible {

    public var asViewCell: ViewCell { self }
}

public extension ViewCellConvertible {

    func with(id: AnyHashable) -> ViewCell {
        var cell = asViewCell
        cell.id = id
        return cell
    }

    func with<V>(_ keyPath: WritableKeyPath<ViewCell.Values, V>, _ value: V) -> ViewCell {
        var cell = asViewCell
        cell.values[keyPath: keyPath] = value
        return cell
    }
    
    func transform<V>(_ keyPath: WritableKeyPath<ViewCell.Values, V>, _ value: (inout V) -> Void) -> ViewCell {
        var cell = asViewCell
        var oldValue = cell.values[keyPath: keyPath]
        value(&oldValue)
        cell.values[keyPath: keyPath] = oldValue
        return cell
    }
    
    func combine<A, B>(_ keyPath: WritableKeyPath<ViewCell.Values, (A, B) -> Void>, with value: @escaping (A, B) -> Void) -> ViewCell {
        var cell = asViewCell
        let oldValue = cell.values[keyPath: keyPath]
        cell.values[keyPath: keyPath] = {
            oldValue($0, $1)
            value($0, $1)
        }
        return cell
    }

    func combine<V>(_ keyPath: WritableKeyPath<ViewCell.Values, (V) -> Void>, with value: @escaping (V) -> Void) -> ViewCell {
        var cell = asViewCell
        let oldValue = cell.values[keyPath: keyPath]
        cell.values[keyPath: keyPath] = {
            oldValue($0)
            value($0)
        }
        return cell
    }

    func combine(_ keyPath: WritableKeyPath<ViewCell.Values, () -> Void>, with value: @escaping () -> Void) -> ViewCell {
        var cell = asViewCell
        let oldValue = cell.values[keyPath: keyPath]
        cell.values[keyPath: keyPath] = {
            oldValue()
            value()
        }
        return cell
    }
    
    func updateIDIfNeeded(id: AnyHashable) -> ViewCell {
        var result = asViewCell
        if result.id.base is NoneID || result.id.base is CodeID {
            result.id = id
        }
        return result
    }
}

public extension View {

    func asViewCell(id: AnyHashable) -> ViewCell {
        ViewCell(id: id, self)
    }
}
