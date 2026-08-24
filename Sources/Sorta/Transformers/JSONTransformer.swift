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

        // 1. Prettify JSON (with sorted keys)
        if let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            options.append(TransformOption(
                title: "Prettify JSON",
                detail: "Formatted with 2-space indentation & sorted keys",
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
                detail: "Single line compact representation",
                shortcutKey: "\(index)",
                transformedContent: minifyString
            ))
            index += 1
        }

        // Extract dictionary or merge array of dictionaries for type generation
        let dictionaryRepresentation: [String: Any]? = {
            if let dict = jsonObject as? [String: Any] {
                return dict
            } else if let array = jsonObject as? [[String: Any]], !array.isEmpty {
                var merged: [String: Any] = [:]
                for item in array {
                    for (k, v) in item {
                        if merged[k] == nil {
                            merged[k] = v
                        }
                    }
                }
                return merged
            }
            return nil
        }()

        if let dict = dictionaryRepresentation {
            // 3. TypeScript Interface
            let tsInterface = generateTypeScriptType(from: dict, name: "GeneratedType")
            options.append(TransformOption(
                title: "TypeScript Interface",
                detail: "interface GeneratedType { ... }",
                shortcutKey: "\(index)",
                transformedContent: tsInterface
            ))
            index += 1

            // 4. Swift Codable Struct
            let swiftStruct = generateSwiftStruct(from: dict, name: "GeneratedItem")
            options.append(TransformOption(
                title: "Swift Codable Struct",
                detail: "struct GeneratedItem: Codable { ... }",
                shortcutKey: "\(index)",
                transformedContent: swiftStruct
            ))
        }

        return options
    }

    private func generateTypeScriptType(from dict: [String: Any], name: String) -> String {
        var lines = ["interface \(name) {"]
        let sortedKeys = dict.keys.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        for key in sortedKeys {
            if let value = dict[key] {
                let typeName = typeNameForTS(value)
                lines.append("  \(key): \(typeName);")
            }
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private func typeNameForTS(_ value: Any) -> String {
        switch value {
        case is String: return "string"
        case is Int, is Double, is Float: return "number"
        case is Bool: return "boolean"
        case let arr as [Any]:
            if let first = arr.first {
                return "\(typeNameForTS(first))[]"
            }
            return "any[]"
        case is [String: Any]: return "Record<string, any>"
        default: return "any"
        }
    }

    private func generateSwiftStruct(from dict: [String: Any], name: String) -> String {
        var lines = ["struct \(name): Codable {"]
        let sortedKeys = dict.keys.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        for key in sortedKeys {
            if let value = dict[key] {
                let typeName = typeNameForSwift(value)
                lines.append("    let \(key): \(typeName)")
            }
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
        case let arr as [Any]:
            if let first = arr.first {
                return "[\(typeNameForSwift(first))]"
            }
            return "[String]"
        case is [String: Any]: return "[String: String]"
        default: return "String"
        }
    }
}
