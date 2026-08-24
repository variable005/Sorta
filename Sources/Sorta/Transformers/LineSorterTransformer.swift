import Foundation

public struct LineSorterTransformer: TransformerProtocol {
    public var category: ClipCategory { .sort }

    public init() {}

    public func detect(content: String) -> Bool {
        let clean = sanitizeInvisibleChars(content)
        let lines = extractLines(clean)
        if lines.count >= 2 {
            return true
        }

        // Check if single line is a comma/semicolon/pipe separated list with 3+ items
        let trimmed = clean.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.contains("\n") {
            for delimiter in [",", ";", "|"] {
                let items = trimmed.split(separator: Character(delimiter)).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                if items.count >= 3 {
                    return true
                }
            }
        }

        return false
    }

    public func transform(content: String) -> [TransformOption] {
        let clean = sanitizeInvisibleChars(content)
        let lines = extractLines(clean)

        var options: [TransformOption] = []
        var index = 1

        if lines.count >= 2 {
            // 1. Sort Lines A-Z (Natural Numeric Order)
            let sortedAZ = lines.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
            let azContent = sortedAZ.joined(separator: "\n")
            if azContent != content {
                options.append(TransformOption(
                    title: "Sort Lines (A-Z Natural)",
                    detail: "Natural alphabetical & numerical order",
                    shortcutKey: "\(index)",
                    transformedContent: azContent
                ))
                index += 1
            }

            // 2. Sort Lines Z-A (Reverse Natural)
            let sortedZA = lines.sorted { $0.localizedStandardCompare($1) == .orderedDescending }
            let zaContent = sortedZA.joined(separator: "\n")
            if zaContent != content {
                options.append(TransformOption(
                    title: "Sort Lines (Z-A Reverse)",
                    detail: "Reverse natural order",
                    shortcutKey: "\(index)",
                    transformedContent: zaContent
                ))
                index += 1
            }

            // 3. Sort & Deduplicate (Unique Lines A-Z)
            var seen = Set<String>()
            var uniqueLines: [String] = []
            for line in sortedAZ {
                let key = line.lowercased().trimmingCharacters(in: .whitespaces)
                if !seen.contains(key) {
                    seen.insert(key)
                    uniqueLines.append(line)
                }
            }
            let uniqueContent = uniqueLines.joined(separator: "\n")
            options.append(TransformOption(
                title: "Sort & Deduplicate (Unique A-Z)",
                detail: "Removes duplicates (\(uniqueLines.count) unique lines)",
                shortcutKey: "\(index)",
                transformedContent: uniqueContent
            ))
            index += 1

            // 4. Sort by Line Length
            let sortedByLength = lines.sorted { l1, l2 in
                if l1.count != l2.count {
                    return l1.count < l2.count
                }
                return l1.localizedStandardCompare(l2) == .orderedAscending
            }
            let lengthContent = sortedByLength.joined(separator: "\n")
            if lengthContent != content && lengthContent != azContent {
                options.append(TransformOption(
                    title: "Sort by Line Length",
                    detail: "Shortest to longest lines",
                    shortcutKey: "\(index)",
                    transformedContent: lengthContent
                ))
            }
        } else {
            // Delimited inline list sorting
            let trimmed = clean.trimmingCharacters(in: .whitespacesAndNewlines)
            for delimiter in [",", ";", "|"] {
                let items = trimmed.split(separator: Character(delimiter)).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                if items.count >= 3 {
                    let sortedItems = items.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
                    let sortedList = sortedItems.joined(separator: "\(delimiter) ")
                    options.append(TransformOption(
                        title: "Sort Delimited List (A-Z)",
                        detail: "Alphabetizes inline list separated by '\(delimiter)'",
                        shortcutKey: "\(index)",
                        transformedContent: sortedList
                    ))
                    break
                }
            }
        }

        return options
    }

    private func extractLines(_ text: String) -> [String] {
        return text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func sanitizeInvisibleChars(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\u{200B}", with: "")
            .replacingOccurrences(of: "\u{200C}", with: "")
            .replacingOccurrences(of: "\u{200D}", with: "")
            .replacingOccurrences(of: "\u{FEFF}", with: "")
    }
}
