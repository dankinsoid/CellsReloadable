import Foundation

extension String {
    
    /// Returns ID string by the current code location.
    public static func codeID(fileID: String = #fileID, line: UInt = #line, column: UInt = #column) -> String {
        "\(fileID):\(line):\(column)"
    }
}
