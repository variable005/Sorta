import Foundation

public struct TextSanitizerTransformer: TransformerProtocol {
    public var category: ClipCategory { .text }

    public init() {}

    public func detect(content: String) -> Bool {
        return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func transform(content: String) -> [TransformOption] {
        var options: [TransformOption] = []
        var index = 1

        // 1. Sanitized Plain Text
        let sanitized = sanitizeText(content)
        if sanitized != content {
            options.append(TransformOption(
                title: "Sanitize Text & Whitespace",
                detail: "Strips hidden zero-width spaces and normalizes line breaks",
                shortcutKey: "\(index)",
                transformedContent: sanitized
            ))
            index += 1
        }

        // 2. Single Line Compact
        let singleLine = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if singleLine != content {
            options.append(TransformOption(
                title: "Single Line Compact",
                detail: "Joins lines with single spaces",
                shortcutKey: "\(index)",
                transformedContent: singleLine
            ))
            index += 1
        }

        // 3. UPPERCASE
        let upper = content.uppercased()
        options.append(TransformOption(
            title: "UPPERCASE",
            detail: upper,
            shortcutKey: "\(index)",
            transformedContent: upper
        ))
        index += 1

        // 4. lowercase
        let lower = content.lowercased()
        options.append(TransformOption(
            title: "lowercase",
            detail: lower,
            shortcutKey: "\(index)",
            transformedContent: lower
        ))
        index += 1

        // 5. Title Case
        let titleCase = content.capitalized
        options.append(TransformOption(
            title: "Title Case",
            detail: titleCase,
            shortcutKey: "\(index)",
            transformedContent: titleCase
        ))

        return options
    }

    private func sanitizeText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\u{200B}", with: "") // Zero-width space
            .replacingOccurrences(of: "\u{200C}", with: "") // Zero-width non-joiner
            .replacingOccurrences(of: "\u{200D}", with: "") // Zero-width joiner
            .replacingOccurrences(of: "\u{FEFF}", with: "") // Byte order mark
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "‘", with: "'")
            .replacingOccurrences(of: "’", with: "'")
    }
}
