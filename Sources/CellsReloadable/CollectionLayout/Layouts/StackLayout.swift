import SwiftUI

public struct HLayout<Content: CollectionLayout>: CollectionLayout {
    
    public var spacing: Double = 0
    public var content: Content
    public var alignment: VerticalAlignment
    
    public init(
        spacing: Double = 0,
        alignment: VerticalAlignment = .center,
        @LayoutBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }
    
    public var body: some CollectionLayout {
        StackLayout(
            .horizontal,
            spacing: spacing,
            alignment: Alignment(horizontal: .center, vertical: alignment)
        ) {
            content
        }
    }
}

public struct VLayout<Content: CollectionLayout>: CollectionLayout {
    
    public var spacing: Double = 0
    public var content: Content
    public var alignment: HorizontalAlignment
    
    public init(
        spacing: Double = 0,
        alignment: HorizontalAlignment = .center,
        @LayoutBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }
    
    public var body: some CollectionLayout {
        StackLayout(
            .vertical,
            spacing: spacing,
            alignment: Alignment(horizontal: alignment, vertical: .center)
        ) {
            content
        }
    }
}

public struct StackLayout<Content: CollectionLayout>: CustomCollectionLayout {
    
    public var axis: NSLayoutConstraint.Axis
    public var spacing: Double = 0
    public var content: Content.Layout
    public var alignment: Alignment

    public var properties: LayoutProperties {
        var result = content.properties
        result.axis = .horizontal
        return result
    }
    
    public init(
        _ axis: NSLayoutConstraint.Axis,
        spacing: Double = 0,
        alignment: Alignment = .center,
        @LayoutBuilder content: () -> Content
    ) {
        self.axis = axis
        self.content = content().layout
        self.alignment = alignment
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal size: ProposedSize,
        context: LayoutContext,
        cache: inout Cache
    ) -> ProposedSize {
        let axisKP = axis.sizeKP
        let axisNormalKP = axis.opposite.sizeKP
        let axisPrKP = axis.proposedSizeKP
        let axisNormalPrKP = axis.opposite.proposedSizeKP
        
        cache.wasInitialized = true
        let children = content.makeLayouts(localID: context.localID)
        cache.children = children
        if cache.caches.count != children.count {
            cache.caches = children.map {
                $0.createCache()
            }
        }
        guard !children.isEmpty else { return .zero }
        let fullSpacing = spacing * Double(max(0, children.count - 1))
        let freeSpace = size[keyPath: axisPrKP].map { max(0, $0 - fullSpacing) }
        var unspecifiedSizes = children.indices.map {
            children[$0].sizeThatFits(
                proposal: ProposedSize(axis, freeSpace, size[keyPath: axisNormalPrKP]),
                context: context,
                cache: &cache.caches[$0]
            )
        }
        var unspecifiedSize = ProposedSize.unspecified
        for itemSize in unspecifiedSizes {
            unspecifiedSize[keyPath: axisNormalPrKP] = max(unspecifiedSize[keyPath: axisNormalPrKP], itemSize[keyPath: axisNormalPrKP])
            if let mainSize = itemSize[keyPath: axisPrKP] {
                unspecifiedSize[keyPath: axisPrKP] = (unspecifiedSize[keyPath: axisPrKP] ?? 0) + mainSize
            }
        }
        if let mainSize = unspecifiedSize[keyPath: axisPrKP] {
            unspecifiedSize[keyPath: axisPrKP] = mainSize + fullSpacing
        }
        
        if let mainSize = size[keyPath: axisPrKP], let unspecMainSize = unspecifiedSize[keyPath: axisPrKP], mainSize < unspecMainSize {
            let dif = mainSize - unspecMainSize
            add(
                dif,
                to: &unspecifiedSizes,
                normalSize: size[keyPath: axisNormalPrKP],
                fullFreeSpaces: freeSpace,
                layouts: children,
                axis: axis,
                caches: &cache.caches,
                context: context
            )
            unspecifiedSize = ProposedSize.unspecified
            for itemSize in unspecifiedSizes {
                unspecifiedSize[keyPath: axisNormalPrKP] = max(unspecifiedSize[keyPath: axisNormalPrKP], itemSize[keyPath: axisNormalPrKP])
                if let mainSize = itemSize[keyPath: axisPrKP] {
                    unspecifiedSize[keyPath: axisPrKP] = (unspecifiedSize[keyPath: axisPrKP] ?? 0) + mainSize
                }
            }
            if let mainSize = unspecifiedSize[keyPath: axisPrKP] {
                unspecifiedSize[keyPath: axisPrKP] = mainSize + fullSpacing
            }
        }
        cache.subviewsSizes = unspecifiedSizes
        return unspecifiedSize
    }
    
    public struct Cache {
        
        var wasInitialized: Bool = false
        var spacing: Double
        var caches: [Any]
        var subviewsSizes: [ProposedSize] = []
        var children: [AnyCollectionLayout] = []
    }
    
    public func createCache() -> Cache {
        Cache(
            spacing: spacing,
            caches: []
        )
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        context: LayoutContext,
        cache: inout Cache,
        place: (ViewCell, CGRect) -> Void
    ) {
        if !cache.wasInitialized {
            _ = sizeThatFits(
                proposal: ProposedSize(bounds.size),
                context: context,
                cache: &cache
            )
        }
        let children = cache.children
        guard !children.isEmpty else { return }
        let sizeKP = axis.proposedSizeKP
        let normalKP = axis.opposite.proposedSizeKP
        var origin = axis == .horizontal ? bounds.minX : bounds.minY
        let minNormal = axis == .horizontal ? bounds.minY : bounds.minX
        let maxSize = cache.subviewsSizes.reduce(0) { max($0, $1[keyPath: normalKP]) }
        for i in children.indices {
            let mainSize = cache.subviewsSizes[i][keyPath: sizeKP] ?? bounds.size[keyPath: axis.sizeKP]
            let rect = CGRect(
                origin: CGPoint(axis, origin, minNormal),
                size: CGSize(
                    axis,
                    mainSize ?? bounds.size[keyPath: axis.sizeKP],
                    maxSize ?? bounds.size[keyPath: axis.opposite.sizeKP]
                )
            )
            .frame(
                size: CGSize(
                    width: cache.subviewsSizes[i].width ?? bounds.width,
                    height: cache.subviewsSizes[i].height ?? bounds.height
                ),
                alignment: alignment
            )
            children[i].placeSubviews(
                in: rect,
                context: context,
                cache: &cache.caches[i],
                place: place
            )
            origin += mainSize + cache.spacing
        }
    }

    public func makeItems(localID: some Hashable) -> [ViewCell] {
        content.makeItems(localID: localID)
    }
    
    public func makeLayouts(localID: some Hashable) -> [AnyCollectionLayout] {
        [AnyCollectionLayout(self)]
    }
}

private func add(
    _ value: Double,
    to sizes: inout [ProposedSize],
    normalSize: Double?,
    fullFreeSpaces: Double?,
    layouts: [AnyCollectionLayout],
    axis: NSLayoutConstraint.Axis,
    caches: inout [Any],
    context: LayoutContext
) {
    guard value != 0 else { return }
    let sizeKP = axis.proposedSizeKP
    var value = value
    let priorityGroups = Dictionary(grouping: layouts.enumerated()) {
        $0.element.properties.priority//[keyPath: sizeKP]
    }
        .lazy
        .sorted {
            $0.key < $1.key
        }
        .map {
            Dictionary(grouping: $0.value) {
                sizes[$0.offset][keyPath: sizeKP] == nil
            }
            .sorted { f, _ in
                f.key == true
            }
            .map(\.value)
        }
    for sizeGroups in priorityGroups {
        for group in sizeGroups {
            var index = 0
            for (i, layout) in group {
                let eachValue = value / Double(group.count - index)
                let oldValue = sizes[i][keyPath: sizeKP]
                sizes[i] = layout.sizeThatFits(
                    proposal: ProposedSize(
                        axis,
                        sizes[i][keyPath: sizeKP] + eachValue,
                        normalSize
                    ),
                    context: context,
                    cache: &caches[i]
                )
                let newValue = sizes[i][keyPath: sizeKP]
                value -= (newValue - oldValue)
                if abs(value) <= 0.001 {
                    return
                }
                index += 1
            }
        }
    }
}

private struct HLayoutVisitor: LayoutVisitor {
    
    var layouts: [AnyCollectionLayout] = []
    
    mutating func visit(with layout: some CollectionLayout) {
        layouts.append(AnyCollectionLayout(layout))
    }
}
