import UIKit
import Carbon

/// ViewCell helper struct with view generic, available through `Cell` typealias.
///
/// ```
///  SomeView.Cell(with: props)
/// ```
public struct TypedViewCell<Content: UIView>: Identifiable, IdentifiableComponent {

    public var id: AnyHashable
    public let render: (Content) -> Void

    public init(
        id: AnyHashable,
        render: @escaping (Content) -> Void = { _ in }
    ) {
        self.id = id
        self.render = render
    }
    
    public func renderContent() -> Content {
        Content()
    }
    
    public func render(in content: Content) {
        render(content)
    }
}

public extension TypedViewCell where Content: RenderableView {

    init(
        id: AnyHashable,
        with props: Content.Props
    ) {
        self.init(id: id) {
            $0.render(with: props)
        }
    }
}

public extension TypedViewCell where Content: RenderableView, Content.Props: Identifiable {

    init(
        with props: Content.Props
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
