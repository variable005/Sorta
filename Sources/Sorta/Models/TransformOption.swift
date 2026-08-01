import Foundation

public struct TransformOption: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let detail: String
    public let shortcutKey: String?
    public let transformedContent: String

    public init(id: String = UUID().uuidString, title: String, detail: String, shortcutKey: String? = nil, transformedContent: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.shortcutKey = shortcutKey
        self.transformedContent = transformedContent
    }
}
