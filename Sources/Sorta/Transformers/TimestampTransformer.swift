import Foundation

public struct TimestampTransformer: TransformerProtocol {
    public var category: ClipCategory { .timestamp }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmed) else { return false }
        // 10 digits (seconds, e.g. 1700000000) or 13 digits (milliseconds, e.g. 1700000000000)
        return (value >= 1_000_000_000 && value <= 4_000_000_000) || (value >= 1_000_000_000_000 && value <= 4_000_000_000_000)
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var value = Double(trimmed) else { return [] }

        // If milliseconds, convert to seconds
        if value > 4_000_000_000 {
            value /= 1000.0
        }

        let date = Date(timeIntervalSince1970: value)

        var options: [TransformOption] = []
        var index = 1

        // 1. ISO-8601 Format
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        let isoString = isoFormatter.string(from: date)
        options.append(TransformOption(
            title: "ISO-8601 UTC String",
            detail: isoString,
            shortcutKey: "\(index)",
            transformedContent: isoString
        ))
        index += 1

        // 2. Human Readable Local Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        let localString = dateFormatter.string(from: date)
        options.append(TransformOption(
            title: "Local Date & Time String",
            detail: localString,
            shortcutKey: "\(index)",
            transformedContent: localString
        ))
        index += 1

        // 3. Relative Time String
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        let relativeString = relativeFormatter.localizedString(for: date, relativeTo: Date())
        options.append(TransformOption(
            title: "Relative Time Description",
            detail: relativeString,
            shortcutKey: "\(index)",
            transformedContent: relativeString
        ))

        return options
    }
}
