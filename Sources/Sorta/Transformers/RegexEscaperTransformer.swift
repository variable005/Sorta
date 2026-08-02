import Foundation

public struct RegexEscaperTransformer: TransformerProtocol {
    public var category: ClipCategory { .regex }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.hasPrefix("/") && trimmed.hasSuffix("/")) || trimmed.contains("\\d") || trimmed.contains("\\w") || trimmed.contains("\\s")
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        var options: [TransformOption] = []
        var index = 1

        // 1. Escaped for Double Quote String Literals
        let escapedDouble = trimmed.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        options.append(TransformOption(
            title: "Escape String Literal (JS/Python/Swift)",
            detail: escapedDouble,
            shortcutKey: "\(index)",
            transformedContent: escapedDouble
        ))
        index += 1

        // 2. Swift Raw String Literal (#"..."#)
        let swiftRaw = "#\"\(trimmed)\"#"
        options.append(TransformOption(
            title: "Swift Raw String Literal",
            detail: swiftRaw,
            shortcutKey: "\(index)",
            transformedContent: swiftRaw
        ))

        return options
    }
}
