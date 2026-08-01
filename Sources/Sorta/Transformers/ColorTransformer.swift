import Foundation
import AppKit

public struct ColorTransformer: TransformerProtocol {
    public var category: ClipCategory { .color }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return parseHexColor(trimmed) != nil || parseRGBColor(trimmed) != nil
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let (r, g, b) = parseHexColor(trimmed) ?? parseRGBColor(trimmed) else { return [] }

        let rf = Double(r) / 255.0
        let gf = Double(g) / 255.0
        let bf = Double(b) / 255.0

        var options: [TransformOption] = []
        var index = 1

        // 1. SwiftUI Color
        let swiftUIString = String(format: "Color(red: %.3f, green: %.3f, blue: %.3f)", rf, gf, bf)
        options.append(TransformOption(
            title: "SwiftUI Color Code",
            detail: swiftUIString,
            shortcutKey: "\(index)",
            transformedContent: swiftUIString
        ))
        index += 1

        // 2. NSColor
        let nsColorString = String(format: "NSColor(red: %.3f, green: %.3f, blue: %.3f, alpha: 1.0)", rf, gf, bf)
        options.append(TransformOption(
            title: "AppKit NSColor Code",
            detail: nsColorString,
            shortcutKey: "\(index)",
            transformedContent: nsColorString
        ))
        index += 1

        // 3. RGB Tuple
        let rgbString = "rgb(\(r), \(g), \(b))"
        options.append(TransformOption(
            title: "CSS RGB Tuple",
            detail: rgbString,
            shortcutKey: "\(index)",
            transformedContent: rgbString
        ))
        index += 1

        // 4. Hex Color uppercase
        let hexString = String(format: "#%02X%02X%02X", r, g, b)
        options.append(TransformOption(
            title: "Hex Color String",
            detail: hexString,
            shortcutKey: "\(index)",
            transformedContent: hexString
        ))

        return options
    }

    private func parseHexColor(_ string: String) -> (Int, Int, Int)? {
        var clean = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasPrefix("#") {
            clean.removeFirst()
        }
        guard clean.count == 6, let hexNum = UInt32(clean, radix: 16) else { return nil }
        let r = Int((hexNum >> 16) & 0xFF)
        let g = Int((hexNum >> 8) & 0xFF)
        let b = Int(hexNum & 0xFF)
        return (r, g, b)
    }

    private func parseRGBColor(_ string: String) -> (Int, Int, Int)? {
        let lower = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lower.hasPrefix("rgb(") && lower.hasSuffix(")") else { return nil }
        let body = lower.dropFirst(4).dropLast(1)
        let parts = body.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 3 else { return nil }
        return (parts[0], parts[1], parts[2])
    }
}
