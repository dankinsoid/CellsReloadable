import Foundation

public protocol ViewCellsVisitor {
    
    mutating func visit(with cells: [ViewCell])
}

public protocol LayoutVisitor {
    
    mutating func visit(with layout: some CollectionLayout)
}
