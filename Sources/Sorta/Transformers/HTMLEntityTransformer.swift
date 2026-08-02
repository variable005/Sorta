import Foundation

public struct HTMLEntityTransformer: TransformerProtocol {
    public var category: ClipCategory { .htmlEntity }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("&lt;") || trimmed.contains("&gt;") || trimmed.contains("&amp;") || trimmed.contains("&quot;") || trimmed.contains("&#39;")
    }

    public func transform(content: String) -> [TransformOption] {
        var options: [TransformOption] = []
        var index = 1

        let decoded = decodeEntities(content)
        if decoded != content {
            options.append(TransformOption(
                title: "Decode HTML Entities",
                detail: decoded,
                shortcutKey: "\(index)",
                transformedContent: decoded
            ))
            index += 1
        }

        let encoded = encodeEntities(content)
        if encoded != content {
            options.append(TransformOption(
                title: "Encode HTML Entities",
                detail: encoded,
                shortcutKey: "\(index)",
                transformedContent: encoded
            ))
        }

        return options
    }

    private func decodeEntities(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    private func encodeEntities(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
