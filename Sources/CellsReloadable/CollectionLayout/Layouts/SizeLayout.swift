import UIKit

public extension CollectionLayout {
    
    func size(width: Double?, height: Double?) -> some CollectionLayout {
        SizeLayout(base: self, width: width, height: height)
    }
    
    func size(_ size: Double?) -> some CollectionLayout {
        SizeLayout(base: self, width: size, height: size)
    }
    
    func size(_ size: CGSize) -> some CollectionLayout {
        SizeLayout(base: self, width: size.width, height: size.height)
    }
    
    func size(width: Double?) -> some CollectionLayout {
        SizeLayout(base: self, width: width)
    }
    
    func size(height: Double?) -> some CollectionLayout {
        SizeLayout(base: self, height: height)
    }
    
    func size(
        minWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        maxHeight: Double? = nil
    ) -> some CollectionLayout {
        SizeLayout(base: self, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
    }
}

private struct SizeLayout<Base: CollectionLayout>: CollectionLayout {
    
    let base: Base
    var width: Double?
    var height: Double?
    var minWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var maxHeight: Double?
    
    var properties: LayoutProperties {
        var result = base.properties
        result.priority = 1
        return result
    }
    
    func sizeThatFits(proposal: ProposedSize, context: LayoutContext, cache: inout Base.Cache) -> CGSize {
        if let width, let height {
            return CGSize(width: width, height: height)
        } else {
            let sizeThatFits = base.sizeThatFits(
                proposal: ProposedSize(
                    width: width(for: proposal.width),
                    height: height(for: proposal.height)
                ),
                context: context,
                cache: &cache
            )
            return CGSize(
                width: width(for: sizeThatFits.width) ?? sizeThatFits.width,
                height: height(for: sizeThatFits.height) ?? sizeThatFits.height
            )
        }
    }
    
    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Base.Cache, place: (ViewCell, CGRect) -> Void) {
        base.placeSubviews(in: bounds, context: context, cache: &cache, place: place)
    }
    
    func createCache() -> Base.Cache {
        base.createCache()
    }
    
    func makeItems(visitor: inout some ViewCellsVisitor, localID: some Hashable) {
        base.makeItems(visitor: &visitor, localID: localID)
    }
    
    private func height(for value: Double?) -> Double? {
        guard height == nil else { return height }
        guard let value else { return nil }
        return max(minHeight ?? value, min(maxHeight ?? value, value))
    }
    
    private func width(for value: Double?) -> Double? {
        guard width == nil else { return width }
        guard let value else { return nil }
        return max(minWidth ?? value, min(maxWidth ?? value, value))
    }
}
