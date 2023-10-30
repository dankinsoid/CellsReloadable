import UIKit

public class CollectionView: UICollectionView {
    
    private lazy var loader = UICollectionViewReloader(self, isAnimated: true)
    private let layout = CellsSectionLayout()
    private var lastSize: CGSize?
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: self.layout)
    }
    
    required public init?(coder: NSCoder) {
        super.init(frame: .zero, collectionViewLayout: self.layout)
    }
    
    public func reload<L: CollectionLayout>(@LayoutBuilder items: () -> L) {
        let items = items()
        layout.layout = AnyCollectionLayout(items)
        var visitor = CollectViewCellsVisitor()
        items.makeItems(visitor: &visitor, localID: NoneID())
        loader.reload(cells: visitor.cells, completion: nil)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if lastSize != frame.size, window != nil {
            lastSize = frame.size
            layout.invalidateLayout()
        }
    }
}
