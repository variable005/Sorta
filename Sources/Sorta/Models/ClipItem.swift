import Foundation

public struct ClipItem: Identifiable, Equatable, Codable, Hashable {
    public let id: UUID
    public let rawContent: String
    public let categoryRaw: String
    public let createdAt: Date
    public var lastTransformedContent: String?
    public var isPinned: Bool

    public var category: ClipCategory {
        ClipCategory(rawValue: categoryRaw) ?? .text
    }

    public init(
        id: UUID = UUID(),
        rawContent: String,
        category: ClipCategory,
        createdAt: Date = Date(),
        lastTransformedContent: String? = nil,
        isPinned: Bool = false
    ) {
        self.id = id
        self.rawContent = rawContent
        self.categoryRaw = category.rawValue
        self.createdAt = createdAt
        self.lastTransformedContent = lastTransformedContent
        self.isPinned = isPinned
    }
}
