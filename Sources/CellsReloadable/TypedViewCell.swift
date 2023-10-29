import UIKit

/// ViewCell helper struct with view generic, available through `Cell` typealias.
///
/// ```
///  SomeView.Cell(with: props)
/// ```
public struct TypedViewCell<Cell: UIView>: ViewCellConvertible, Identifiable {

    public var id: AnyHashable
    public let render: (Cell) -> Void

    public init(
        id: AnyHashable = NoneID(),
        render: @escaping (Cell) -> Void = { _ in }
    ) {
        self.id = id
        self.render = render
    }

    public var asViewCell: ViewCell {
        ViewCell(id: id, create: Cell.init, render: render)
    }
}

public extension TypedViewCell where Cell: RenderableView {

    @_disfavoredOverload
    init(
        id: AnyHashable = NoneID(),
        with props: Cell.Props
    ) {
        self.init(id: id) {
            $0.render(with: props)
        }
    }
}

public extension TypedViewCell where Cell: RenderableView, Cell.Props: Identifiable {

    init(
        with props: Cell.Props
    ) {
        self.init(id: props.id) {
            $0.render(with: props)
        }
    }
}

public extension NSObjectProtocol where Self: UIView {

    /// ViewCell helper typealias.
    typealias Cell = TypedViewCell<Self>
}
