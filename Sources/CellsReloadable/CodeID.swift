import Foundation

/// Identifier of caller location
public struct CodeID: Hashable {

    public let fileID: String
    public let line: UInt
    public let column: UInt

    public init(fileID: String = #fileID, line: UInt = #line, column: UInt = #column) {
        self.fileID = fileID
        self.line = line
        self.column = column
    }
}
