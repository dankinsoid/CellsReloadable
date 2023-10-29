import UIKit

public protocol ViewCellsCollection {
    
    func visit<V: ViewCellsVisitor>(with visitor: inout V)
}

public protocol ViewCellsVisitor {
    
    mutating func visit<ID: Hashable>(with array: ViewCellsArray, localID: ID)
}

public struct ViewCellsArray {
    
    public let cells: [ViewCell]
    
    public init() {
        cells = []
    }
    
    init(_ collection: some ViewCellsCollection) {
        var visitor = Visitor()
        collection.visit(with: &visitor)
        cells = visitor.cells
    }
    
    init(cell: ViewCell) {
        cells = [cell]
    }
    
    private struct Visitor: ViewCellsVisitor {
        
        var cells: [ViewCell] = []
        
        mutating func visit<ID>(with array: ViewCellsArray, localID: ID) where ID : Hashable {
            cells += array.cells.map {
                $0.with(id: UnionID($0.id, localID))
            }
        }
    }
}

extension ViewCell: ViewCellsCollection {

    public func visit<V: ViewCellsVisitor>(with visitor: inout V) {
        visitor.visit(with: ViewCellsArray(cell: self), localID: id)
    }
}

extension ViewCellConvertible where Self: ViewCellConvertible {
    
    public func visit<V: ViewCellsVisitor>(with visitor: inout V) {
        asViewCell.visit(with: &visitor)
    }
}

struct OptionalViewCells: ViewCellsCollection {
    
    var cells: ViewCellsArray?
    
    func visit<V: ViewCellsVisitor>(with visitor: inout V) {
        if let cells {
            visitor.visit(with: cells, localID: true)
        } else {
            visitor.visit(with: ViewCellsArray(), localID: false)
        }
    }
}

enum IfViewCells: ViewCellsCollection {
    
    case `true`(ViewCellsArray)
    case `false`(ViewCellsArray)
    
    func visit<V: ViewCellsVisitor>(with visitor: inout V) {
        switch self {
        case let .true(cells):
            visitor.visit(with: cells, localID: true)
        case let .false(cells):
            visitor.visit(with: cells, localID: false)
        }
    }
}

extension ViewCellsArray {
    
}
