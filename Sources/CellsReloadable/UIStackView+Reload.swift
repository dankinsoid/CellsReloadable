import UIKit

extension UIStackView: ViewCellsReloadable {

    public func reload(
        cells: [ViewCell],
        completion: (() -> Void)?
    ) {
        var subviews = arrangedSubviews
        for cell in cells {
            if let i = firstMatch(for: cell, subviews: subviews) {
                let subview = subviews[i]
                subviews.remove(at: i)
                addArrangedSubview(subview)
                cell.reloadView(subview)
            } else {
                let subview = cell.createView()
                subview.stackID = cell.id
                addArrangedSubview(subview)
                cell.reloadView(subview)
            }
        }
        subviews.forEach {
            $0.removeFromSuperview()
        }
        layoutIfNeeded()
        completion?()
    }

    private func firstMatch(for cell: ViewCell, subviews: [UIView]) -> Int? {
        let result = subviews.firstIndex {
            $0.stackID == cell.id
        }
        return result ?? subviews.firstIndex {
            cell.type == type(of: $0)
        }
    }
}

extension UIStackView: CellsSectionsReloadable {

    public func reload(sections: [CellsSection], completion: (() -> Void)?) {
        if sections.count == 1 {
            configure(with: sections[0].values.stack)
            reload(cells: sections[0].cells, completion: completion)
        } else {
            reload(
                cells: sections.map { section in
                    ViewCell(id: section.id) {
                        UIStackView()
                    } render: { [weak self] stack in
                        stack.axis = self?.axis ?? stack.axis
                        stack.configure(with: section.values.stack)
                        stack.reload(cells: section.cells, completion: nil)
                    }
                },
                completion: completion
            )
        }
    }

    private func configure(with data: CellsSection.Values.Stack) {
        axis = data.axis ?? axis
        spacing = data.spacing ?? spacing
        alignment = data.alignment ?? alignment
        distribution = data.distribution ?? distribution
        backgroundColor = data.backgroundColor ?? backgroundColor
        layer.cornerRadius = data.cornerRadius ?? layer.cornerRadius
        directionalLayoutMargins = data.margins ?? directionalLayoutMargins
        if data.margins != nil {
            isLayoutMarginsRelativeArrangement = true
        }
    }
}

public extension CellsSection.Values {

    var stack: Stack {
        get { self[\.stack] ?? Stack() }
        set { self[\.stack] = newValue }
    }

    struct Stack: Equatable {

        public var axis: NSLayoutConstraint.Axis?
        public var spacing: CGFloat?
        public var alignment: UIStackView.Alignment?
        public var distribution: UIStackView.Distribution?
        public var backgroundColor: UIColor?
        public var cornerRadius: CGFloat?
        public var margins: NSDirectionalEdgeInsets?

        public init() {}
    }
}

private extension UIView {

    enum AssociatedKeys {

        static var stackID = 0
    }

    var stackID: AnyHashable? {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.stackID) as? IDWrapper)?.id
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.stackID,
                newValue.map { IDWrapper($0) },
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

private final class IDWrapper {

    var id: AnyHashable

    init(_ id: AnyHashable) {
        self.id = id
    }
}
