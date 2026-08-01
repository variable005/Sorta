import Foundation

public struct JWTTransformer: TransformerProtocol {
    public var category: ClipCategory { .jwt }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ".")
        guard parts.count == 3 else { return false }
        guard decodeBase64URL(String(parts[0])) != nil,
              decodeBase64URL(String(parts[1])) != nil else {
            return false
        }
        return true
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ".")
        guard parts.count == 3,
              let headerData = decodeBase64URL(String(parts[0])),
              let payloadData = decodeBase64URL(String(parts[1])) else {
            return []
        }

        var options: [TransformOption] = []
        var index = 1

        // 1. Formatted Payload JSON
        if let payloadObj = try? JSONSerialization.jsonObject(with: payloadData, options: []),
           let prettyPayloadData = try? JSONSerialization.data(withJSONObject: payloadObj, options: [.prettyPrinted, .sortedKeys]),
           let prettyPayloadString = String(data: prettyPayloadData, encoding: .utf8) {
            options.append(TransformOption(
                title: "Decoded JWT Payload JSON",
                detail: prettyPayloadString,
                shortcutKey: "\(index)",
                transformedContent: prettyPayloadString
            ))
            index += 1
        }

        // 2. Formatted Header JSON
        if let headerObj = try? JSONSerialization.jsonObject(with: headerData, options: []),
           let prettyHeaderData = try? JSONSerialization.data(withJSONObject: headerObj, options: [.prettyPrinted, .sortedKeys]),
           let prettyHeaderString = String(data: prettyHeaderData, encoding: .utf8) {
            options.append(TransformOption(
                title: "Decoded JWT Header JSON",
                detail: prettyHeaderString,
                shortcutKey: "\(index)",
                transformedContent: prettyHeaderString
            ))
            index += 1
        }

        return options
    }

    private func decodeBase64URL(_ base64URL: String) -> Data? {
        var base64 = base64URL
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }

        return Data(base64Encoded: base64)
    }
}
