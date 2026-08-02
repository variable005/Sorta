import Foundation

public struct Base64Transformer: TransformerProtocol {
    public var category: ClipCategory { .base64 }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 8, trimmed.count % 4 == 0 else { return false }
        let base64Set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=")
        guard CharacterSet(charactersIn: trimmed).isSubset(of: base64Set) else { return false }

        if let data = Data(base64Encoded: trimmed), let decoded = String(data: data, encoding: .utf8), !decoded.isEmpty {
            return true
        }
        return false
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        var options: [TransformOption] = []
        var index = 1

        if let data = Data(base64Encoded: trimmed), let decoded = String(data: data, encoding: .utf8) {
            options.append(TransformOption(
                title: "Decode Base64 to Plain Text",
                detail: decoded,
                shortcutKey: "\(index)",
                transformedContent: decoded
            ))
            index += 1
        }

        if let data = content.data(using: .utf8) {
            let encoded = data.base64EncodedString()
            options.append(TransformOption(
                title: "Encode Text to Base64",
                detail: encoded,
                shortcutKey: "\(index)",
                transformedContent: encoded
            ))
        }

        return options
    }
}
