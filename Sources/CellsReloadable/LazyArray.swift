import Foundation

/// A collection that lazily creates its elements.
public struct LazyArray<Element>: RangeReplaceableCollection, RandomAccessCollection {

    public var startIndex: Int { 0 }
    public var endIndex: Int { _count() }

    private let _count: () -> Int
    private let _element: (Int) -> Element

    public init() {
        self.init(count: 0) { _ in
            fatalError("Index out of range")
        }
    }

    public init(
        count: @escaping @autoclosure () -> Int,
        element: @escaping (Int) -> Element
    ) {
        self.init(count: count, element: element)
    }

    public init(
        count: @escaping () -> Int,
        element: @escaping (Int) -> Element
    ) {
        self._count = count
        self._element = element
    }

    public init<Data: RandomAccessCollection>(
        _ data: Data
    ) where Data.Element == Element {
        self.init(
            count: data.count,
            element: { data[data.index(data.startIndex, offsetBy: $0)] }
        )
    }

    public subscript(position: Int) -> Element {
        _element(position)
    }

    public subscript(bounds: Range<Int>) -> Slice<LazyArray<Element>> {
        Slice(base: self, bounds: bounds)
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where Element == C.Element {
        let newSubrange = subrange.lowerBound ..< (subrange.lowerBound + newElements.count)
        self = .init(
            count: { [_count] in Swift.max(0, _count() + newElements.count - subrange.count) },
            element: { [_element] index in
                if index < subrange.lowerBound {
                    return _element(index)
                } else if newSubrange.contains(index) {
                    return newElements[newElements.index(newElements.startIndex, offsetBy: index - newSubrange.lowerBound)]
                } else {
                    return _element(index - newElements.count + subrange.count)
                }
            }
        )
    }
}

extension LazyArray: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension LazyArray: CustomStringConvertible {

    public var description: String {
        "LazyArray<\(Element.self)>(\(_count()) elements)"
    }
}

extension LazyArray {

    public func map<T>(_ transform: @escaping (Element) -> T) -> LazyArray<T> {
        LazyArray<T>(
            count: { self._count() },
            element: { index in
                let element = self._element(index)
                return transform(element)
            }
        )
    }
}

extension LazyArray: Decodable where Element: Decodable {

    public init(from decoder: Decoder) throws {
        try self.init(Array(from: decoder))
    }
}

extension LazyArray: Encodable where Element: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

extension LazyArray: Equatable where Element: Equatable {

    public static func == (lhs: LazyArray<Element>, rhs: LazyArray<Element>) -> Bool {
        guard lhs._count() == rhs._count() else {
            return false
        }
        for index in 0 ..< lhs._count() {
            guard lhs._element(index) == rhs._element(index) else {
                return false
            }
        }
        return true
    }
}

extension LazyArray: Hashable where Element: Hashable {

    public func hash(into hasher: inout Hasher) {
        for index in 0 ..< _count() {
            hasher.combine(_element(index))
        }
    }
}
