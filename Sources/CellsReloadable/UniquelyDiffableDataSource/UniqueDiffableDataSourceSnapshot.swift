import Foundation
import UIKit

@dynamicMemberLookup
final class UniqueDiffableDataSourceSnapshot<SectionType, ItemType> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<HashableByID<SectionType, AnyHashable>, HashableByID<ItemType, AnyHashable>>

    var snapshot = Snapshot()
    var hasDuplicatedKeys = false
    private let itemID: (ItemType) -> AnyHashable
    private let sectionID: (SectionType) -> AnyHashable

    init<ItemID: Hashable, SectionID: Hashable>(
        itemID: @escaping (ItemType) -> ItemID,
        sectionID: @escaping (SectionType) -> SectionID
    ) {
        self.itemID = itemID
        self.sectionID = sectionID
    }

    func appendSections(_ sections: [SectionType]) {
        snapshot.appendSections(convertUniqueToSections(sections))
    }

    func appendItems(_ items: [ItemType]) {
        let uniqueItems = convertToUniqueItems(items)
        snapshot.appendItems(uniqueItems)
        reconfigureItems(uniqueItems)
    }

    func appendItems(_ items: [ItemType], toSection sectionIdentifier: SectionType? = nil) {
        let uniqueItems = convertToUniqueItems(items)
        snapshot.appendItems(uniqueItems, toSection: sectionIdentifier.map(convertToSection))
        reconfigureItems(uniqueItems)
    }
    
    func reconfigureItems(_ items: [HashableByID<ItemType, AnyHashable>]) {
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems(items)
        } else {
            snapshot.reloadItems(items)
        }
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Snapshot, T>) -> T {
        snapshot[keyPath: keyPath]
    }
}

extension UniqueDiffableDataSourceSnapshot where ItemType: Hashable, SectionType: Hashable {

    @_disfavoredOverload
    convenience init() {
        self.init { $0 } sectionID: { $0 }
    }
}

extension UniqueDiffableDataSourceSnapshot where ItemType: Identifiable, SectionType: Identifiable {

    convenience init() {
        self.init(itemID: \.id, sectionID: \.id)
    }
}

extension UniqueDiffableDataSourceSnapshot where ItemType: Identifiable, SectionType: Hashable {

    convenience init() {
        self.init(itemID: \.id) { $0 }
    }
}

extension UniqueDiffableDataSourceSnapshot<CellsSection.Values, ViewCell>: ViewCellsReloadable {}

extension UniqueDiffableDataSourceSnapshot<CellsSection.Values, ViewCell>: CellsSectionsReloadable {

    func reload(sections: [CellsSection], completion: (() -> Void)?) {
        if !snapshot.sectionIdentifiers.isEmpty {
            snapshot = Snapshot()
        }
        appendSections(sections.map(\.values))
        for section in sections {
            appendItems(section.cells, toSection: section.values)
        }
        completion?()
    }
}

private extension UniqueDiffableDataSourceSnapshot {

    func convertToUniqueItems(_ items: [ItemType]) -> [HashableByID<ItemType, AnyHashable>] {
        var usedItems = Set<AnyHashable>()
        return items.map { item in
            let id = itemID(item)
            if usedItems.contains(id) {
                print("Non-unique item \(id) detected")
                hasDuplicatedKeys = true
                let newID = UUID()
                return HashableByID(item) { _ in newID }
            } else {
                usedItems.insert(id)
                return HashableByID(item, id: itemID)
            }
        }
    }

    func convertUniqueToSections(_ sections: [SectionType]) -> [HashableByID<SectionType, AnyHashable>] {
        var usedSections = Set<AnyHashable>()
        return sections.map { section in
            let id = sectionID(section)
            if usedSections.contains(id) {
                print("Non-unique section \(id) detected")
                hasDuplicatedKeys = true
                let newID = UUID()
                return HashableByID(section) { _ in newID }
            } else {
                usedSections.insert(id)
                return HashableByID(section, id: sectionID)
            }
        }
    }

    func convertToSection(_ section: SectionType) -> HashableByID<SectionType, AnyHashable> {
        HashableByID(section, id: sectionID)
    }
}
