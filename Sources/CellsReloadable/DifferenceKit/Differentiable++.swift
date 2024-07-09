import Foundation
import DifferenceKit

extension ViewCell: Differentiable {
    
    public var differenceIdentifier: AnyHashable {
        id
    }
    
    public func isContentEqual(to source: ViewCell) -> Bool {
        false
    }
}

extension CellsSection: DifferentiableSection {
    
    public var elements: LazyArray<ViewCell> { cells }
    
    public var differenceIdentifier: AnyHashable {
        id
    }
    
    public init(source: CellsSection, elements: some Swift.Collection<ViewCell>) {
        self.init(values: source.values, cells: Array(elements))
    }
    
    public func isContentEqual(to source: CellsSection) -> Bool {
        !hasFooter && !source.hasFooter && !hasHeader && !source.hasHeader
    }
}

private extension CellsSection {
    
    var hasFooter: Bool {
        values.footer != nil
    }
    
    var hasHeader: Bool {
        values.header != nil
    }
}
