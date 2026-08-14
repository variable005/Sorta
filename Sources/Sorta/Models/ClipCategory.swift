import Foundation

public enum CategoryDomain: String, Codable, CaseIterable, Identifiable {
    case devData = "Developer Data"
    case webEncoding = "Web & Encoding"
    case textFormatting = "Text & Formatting"
    case designUtilities = "Design & Utilities"

    public var id: String { rawValue }

    public var systemImageName: String {
        switch self {
        case .devData: return "cpu"
        case .webEncoding: return "network"
        case .textFormatting: return "text.alignleft"
        case .designUtilities: return "slider.horizontal.3"
        }
    }
}

public enum ClipCategory: String, Codable, CaseIterable, Identifiable {
    case url = "URL"
    case json = "JSON"
    case curl = "cURL"
    case color = "Color"
    case timestamp = "Timestamp"
    case jwt = "JWT Token"
    case markdownTable = "Markdown Table"
    case base64 = "Base64"
    case htmlEntity = "HTML Entity"
    case sql = "SQL Query"
    case regex = "Regex"
    case sort = "Line & List Sorter"
    case text = "Plain Text"

    public var id: String { rawValue }

    public var systemImageName: String {
        switch self {
        case .url: return "link"
        case .json: return "curlybraces"
        case .curl: return "terminal"
        case .color: return "paintpalette"
        case .timestamp: return "clock"
        case .jwt: return "key"
        case .markdownTable: return "tablecells"
        case .base64: return "lock.rectangle"
        case .htmlEntity: return "chevron.left.slash.chevron.right"
        case .sql: return "database"
        case .regex: return "asterisk"
        case .sort: return "arrow.up.arrow.down"
        case .text: return "doc.text"
        }
    }

    public var domain: CategoryDomain {
        switch self {
        case .json, .curl, .sql, .jwt:
            return .devData
        case .url, .base64, .htmlEntity:
            return .webEncoding
        case .sort, .markdownTable, .regex, .text:
            return .textFormatting
        case .color, .timestamp:
            return .designUtilities
        }
    }
}

