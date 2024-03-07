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
        let items = items().layout
        layout.layout = AnyCollectionLayout(items)
        loader.reload(cells: items.makeItems(localID: NoneID()), completion: nil)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if lastSize != frame.size, window != nil {
            lastSize = frame.size
            layout.invalidateLayout()
        }
    }
}

import SwiftUI

struct CollectionViewRepresentable<L: CollectionLayout>: UIViewRepresentable {

    let layout: L
    
    init(@LayoutBuilder layout: () -> L) {
        self.layout = layout()
    }
    
    func makeUIView(context: Context) -> CollectionView {
        CollectionView()
    }

    func updateUIView(_ uiView: CollectionView, context: Context) {
        uiView.reload {
            layout
        }
    }
}

enum CollectionViewPreview: PreviewProvider {
    
    static var previews: some View {
        CollectionViewRepresentable {
            HLayout(spacing: 10) {
                ForEachLayout(0..<10) { i in
                    ViewCell {
                        UILabel()
                    } render: { label in
//                        label.textColor = .white
                        label.backgroundColor = .green
                        label.textAlignment = .center
                        label.text = "Text \(i)"
                    }
                    .size(100)
                }
//                .background {
//                    UIColor.blue
//                }
            }
            .height(100)
        }
    }
}
