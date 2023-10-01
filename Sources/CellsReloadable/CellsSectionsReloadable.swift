import Foundation

public protocol CellsSectionsReloadable: ViewCellsReloadable {

    func reload(
        sections: [CellsSection],
        completion: (() -> Void)?
    )
}

public extension ViewCellsReloadable where Self: CellsSectionsReloadable {

    func reload(cells: [ViewCell], completion: (() -> Void)?) {
        reload(sections: [CellsSection(id: "0", cells: cells)], completion: completion)
    }
}

public extension CellsSectionsReloadable {

    func reloadSections(@CellsSectionsBuilder sections: () -> [CellsSection], completion: (() -> Void)? = nil) {
        reload(sections: sections(), completion: completion)
    }
}
