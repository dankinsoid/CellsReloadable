import Foundation

struct HashableByID<Value, ID: Hashable>: Hashable, Identifiable {

    var id: ID { _id(value) }
    private let _id: (Value) -> ID
    let value: Value

    init(_ value: Value, id: @escaping (Value) -> ID) {
        _id = id
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HashableByID, rhs: HashableByID) -> Bool {
        lhs.id == rhs.id
    }
}
