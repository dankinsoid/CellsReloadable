import UIKit

// This class provides a wrapper for a diffable data source, preventing crashes
// when duplicate elements exist in the collection. In such cases, a new UUID is
// generated for each newer instance of the same element.

// Example:
//
// Source elemenets -
// [1, 1, 2, 3, 4, 5, 4]
//
// After applying the snapshot -
// [1, New UUID, 2, 3, 4, 5, New UUID]

final class UniquelyTableDiffableDataSource
<SectionIdentifierType, ItemIdentifierType>:
    UITableViewDiffableDataSource<HashableByID<SectionIdentifierType, AnyHashable>, HashableByID<ItemIdentifierType, AnyHashable>> {

    typealias CellProvider = (_ tableView: UITableView, _ indexPath: IndexPath, _ itemIdentifier: ItemIdentifierType) -> UITableViewCell?

    init(
        tableView: UITableView,
        cellProvider: @escaping CellProvider
    ) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            cellProvider(tableView, indexPath, itemIdentifier.value)
        }
    }

    func apply(
        _ snapshot: UniqueDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        super.apply(snapshot.snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
}

final class UniquelyCollectionDiffableDataSource
<SectionIdentifierType, ItemIdentifierType>:
    UICollectionViewDiffableDataSource<HashableByID<SectionIdentifierType, AnyHashable>, HashableByID<ItemIdentifierType, AnyHashable>> {

    typealias CellProvider = (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ itemIdentifier: ItemIdentifierType)
        -> UICollectionViewCell?

    init(
        collectionView: UICollectionView,
        cellProvider: @escaping CellProvider
    ) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            cellProvider(collectionView, indexPath, itemIdentifier.value)
        }
    }

    func apply(
        _ snapshot: UniqueDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        super.apply(snapshot.snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
}
