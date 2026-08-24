import Foundation

public enum ClipCategory: String, Codable, CaseIterable, Identifiable {
    case image = "Image"
    case url = "URL"
    case json = "JSON"
    case curl = "cURL"
    case jwt = "JWT"
    case timestamp = "Timestamp"
    case color = "Color"
    case base64 = "Base64"
    case text = "Text"

    public var id: String { rawValue }

    public var systemImageName: String {
        switch self {
        case .image: return "photo"
        case .url: return "link"
        case .json: return "curlybraces"
        case .curl: return "terminal"
        case .jwt: return "key.horizontal"
        case .timestamp: return "clock"
        case .color: return "paintpalette"
        case .base64: return "lock.rectangle"
        case .text: return "doc.text"
        }
    }
}
