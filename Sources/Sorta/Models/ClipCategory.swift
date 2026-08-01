import Foundation

public enum ClipCategory: String, Codable, CaseIterable, Identifiable {
    case url = "URL"
    case json = "JSON"
    case curl = "cURL"
    case color = "Color"
    case timestamp = "Timestamp"
    case jwt = "JWT Token"
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
        case .text: return "doc.text"
        }
    }
}
