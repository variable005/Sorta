import Foundation

public struct JSONTransformer: TransformerProtocol {
    public var category: ClipCategory { .json }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) || (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) else {
            return false
        }
        guard let data = trimmed.data(using: .utf8) else { return false }
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return true
        } catch {
            return false
        }
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return []
        }

        var options: [TransformOption] = []
        var index = 1

        // 1. Prettify JSON
        if let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            options.append(TransformOption(
                title: "Prettify JSON",
                detail: "Formatted JSON with 2-space indentation",
                shortcutKey: "\(index)",
                transformedContent: prettyString
            ))
            index += 1
        }

        // 2. Minify JSON
        if let minifyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
           let minifyString = String(data: minifyData, encoding: .utf8) {
            options.append(TransformOption(
                title: "Minify JSON",
                detail: "Single line compact JSON string",
                shortcutKey: "\(index)",
                transformedContent: minifyString
            ))
            index += 1
        }

        // 3. TypeScript Interface
        if let dict = jsonObject as? [String: Any] {
            let tsInterface = generateTypeScriptType(from: dict, name: "GeneratedType")
            options.append(TransformOption(
                title: "Generate TypeScript Interface",
                detail: "interface GeneratedType { ... }",
                shortcutKey: "\(index)",
                transformedContent: tsInterface
            ))
            index += 1

            // 4. Swift Codable Struct
            let swiftStruct = generateSwiftStruct(from: dict, name: "GeneratedItem")
            options.append(TransformOption(
                title: "Generate Swift Codable Struct",
                detail: "struct GeneratedItem: Codable { ... }",
                shortcutKey: "\(index)",
                transformedContent: swiftStruct
            ))
            index += 1
        }

        return options
    }

    private func generateTypeScriptType(from dict: [String: Any], name: String) -> String {
        var lines = ["interface \(name) {"]
        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            let typeName = typeNameForTS(value)
            lines.append("  \(key): \(typeName);")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func typeNameForTS(_ value: Any) -> String {
        switch value {
        case is String: return "string"
        case is Int, is Double, is Float: return "number"
        case is Bool: return "boolean"
        case is [Any]: return "any[]"
        case is [String: Any]: return "Record<string, any>"
        default: return "any"
        }
    }

    private func generateSwiftStruct(from dict: [String: Any], name: String) -> String {
        var lines = ["struct \(name): Codable {"]
        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            let typeName = typeNameForSwift(value)
            lines.append("    let \(key): \(typeName)")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func typeNameForSwift(_ value: Any) -> String {
        switch value {
        case is String: return "String"
        case is Int: return "Int"
        case is Double, is Float: return "Double"
        case is Bool: return "Bool"
        case is [Any]: return "[AnyCodable]"
        case is [String: Any]: return "[String: AnyCodable]"
        default: return "String"
        }
    }
}
