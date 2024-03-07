import SwiftUI

public extension CollectionLayout {
    
    func size(_ width: Double?, _ height: Double?, alignment: Alignment = .center) -> some CollectionLayout {
        SizeLayout(base: layout, width: width, height: height, alignment: alignment)
    }
    
    func size(_ size: Double?, alignment: Alignment = .center) -> some CollectionLayout {
        SizeLayout(base: layout, width: size, height: size, alignment: alignment)
    }

    func size(_ size: CGSize, alignment: Alignment = .center) -> some CollectionLayout {
        SizeLayout(base: layout, width: size.width, height: size.height, alignment: alignment)
    }
    
    func width(_ width: Double?, alignment: Alignment = .center) -> some CollectionLayout {
        SizeLayout(base: layout, width: width, alignment: alignment)
    }
    
    func height(_ height: Double?, alignment: Alignment = .center) -> some CollectionLayout {
        SizeLayout(base: layout, height: height, alignment: alignment)
    }
    
    func size(
        minWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        maxHeight: Double? = nil,
        alignment: Alignment = .center
    ) -> some CustomCollectionLayout {
        SizeLayout(base: layout, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, alignment: alignment)
    }
}

private struct SizeLayout<Base: CustomCollectionLayout>: CustomCollectionLayout {
    
    let base: Base
    var width: Double?
    var height: Double?
    var minWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var maxHeight: Double?
    var alignment: Alignment
    
    var properties: LayoutProperties {
        var result = base.layout.properties
        result.priority = 1
        return result
    }
    
    func sizeThatFits(proposal size: ProposedSize, context: LayoutContext, cache: inout Cache) -> ProposedSize {
        let result: ProposedSize
        if let width, let height {
            result = ProposedSize(width: width, height: height)
//        } else if maxWidth != nil, maxHeight != nil, minWidth != nil, minHeight != nil {
//            result = CGSize(
//                width: width(for: size.width, defaultWidth: size.width),
//                height: height(for: size.height, defaultHeight: size.height)
//            )
        } else {
            let sizeThatFits = base.sizeThatFits(
                proposal: ProposedSize(
                    width: width(for: size.width, defaultWidth: nil),
                    height: height(for: size.height, defaultHeight: nil)
                ),
                context: context,
                cache: &cache.base
            )
            result = ProposedSize(
                width: width(for: sizeThatFits.width, defaultWidth: sizeThatFits.width),
                height: height(for: sizeThatFits.height, defaultHeight: sizeThatFits.height)
            )
        }
        cache.size = result
        return result
    }
    
    func placeSubviews(in bounds: CGRect, context: LayoutContext, cache: inout Cache, place: (ViewCell, CGRect) -> Void) {
        let size = cache.size ?? sizeThatFits(
            proposal: ProposedSize(bounds.size),
            context: context, cache: &cache
        )
        base.placeSubviews(
            in: bounds.frame(
                size: CGSize(width: size.width ?? bounds.width, height: size.height ?? bounds.height),
                alignment: alignment
            ),
            context: context,
            cache: &cache.base, place: place
        )
    }
    
    func createCache() -> Cache {
        Cache(base: base.createCache())
    }
    
    func makeItems(localID: some Hashable) -> [ViewCell] {
        base.makeItems(localID: localID)
    }

    func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        base.makeLayouts(localID: localID).map {
            AnyCollectionLayout(SizeLayout<AnyCollectionLayout>(base: $0, alignment: alignment))
        }
    }
    
    struct Cache {
    
        var base: Base.Cache
        var size: ProposedSize?
    }
    
    private func height(for value: Double?, defaultHeight: Double?) -> Double? {
        guard height == nil else { return height }
        guard let value else { return nil }
        return max(minHeight ?? defaultHeight ?? 0, min(maxHeight ?? defaultHeight ?? .infinity, value))
    }

    private func width(for value: Double?, defaultWidth: Double?) -> Double? {
        guard width == nil else { return width }
        guard let value else { return nil }
        return max(minWidth ?? defaultWidth ?? 0, min(maxWidth ?? defaultWidth ?? .infinity, value))
    }
}
