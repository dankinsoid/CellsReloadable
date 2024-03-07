import UIKit

open class CellsSectionLayout: UICollectionViewLayout {
    
    private var allAttributes: [UICollectionViewLayoutAttributes] = []
    private var ids: [AnyHashable] = []
    private var hasWindow = false
    var layout = AnyCollectionLayout(Spacing())
    private var size = CGSize.zero
    
    override open func prepare() {
        guard let collectionView else { return }
        let oldAttributes = hasWindow ? Dictionary(zip(ids, allAttributes)) { _, new in new } : [:]
        allAttributes = []
        hasWindow = collectionView.window != nil
        
        var cache = layout.createCache()
        
        var proposal = ProposedSize.unspecified
        var origin = CGPoint.zero
        if let axis = layout.properties.axis {
            switch axis {
            case .horizontal:
                let dy = collectionView.adjustedContentInset.bottom + collectionView.adjustedContentInset.top
                origin.y = collectionView.adjustedContentInset.top
                proposal.height = collectionView.frame.height - dy
            case .vertical:
                let dx = collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right
                origin.x = collectionView.adjustedContentInset.left
                proposal.width = collectionView.frame.width - dx
            @unknown default:
                break
            }
        }
        
        let context = LayoutContext(
            localID: NoneID(),
            subviews: LayoutSubviews { id in
                collectionView.reloader?.viewForItem(with: id)
            } size: { id in
                oldAttributes[id]?.frame.size
            }
        )
        size = layout.sizeThatFits(
            proposal: proposal,
            context: context,
            cache: &cache
        )
        
        ids = []
        layout.placeSubviews(
            in: CGRect(origin: origin, size: size),
            context: context,
            cache: &cache
        ) { item, rect in
//            print(rect)
            ids.append(item.id)
            let attributes = UICollectionViewLayoutAttributes(
                forCellWith: IndexPath(item: allAttributes.count, section: 0)
            )
            attributes.frame = rect
            allAttributes.append(attributes)
        }
    }
    
    override open var collectionViewContentSize: CGSize {
        size
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        allAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        allAttributes[indexPath.item]
    }
}

struct CollectViewCellsVisitor: ViewCellsVisitor {
    
    var cells: [ViewCell] = []
    
    mutating func visit(with cells: [ViewCell]) {
        self.cells += cells
    }
}
