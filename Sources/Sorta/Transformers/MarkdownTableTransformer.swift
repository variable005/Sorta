import Foundation

public struct MarkdownTableTransformer: TransformerProtocol {
    public var category: ClipCategory { .markdownTable }

    public init() {}

    public func detect(content: String) -> Bool {
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard lines.count >= 2 else { return false }

        let firstRow = parseCSVLine(lines[0], delimiter: lines[0].contains("\t") ? "\t" : ",")
        let secondRow = parseCSVLine(lines[1], delimiter: lines[1].contains("\t") ? "\t" : ",")

        return firstRow.count >= 2 && secondRow.count == firstRow.count
    }

    public func transform(content: String) -> [TransformOption] {
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard lines.count >= 2 else { return [] }

        let isTabDelimited = lines[0].contains("\t")
        let delimiter: Character = isTabDelimited ? "\t" : ","

        let matrix = lines.map { parseCSVLine($0, delimiter: delimiter) }
        guard let columnCount = matrix.first?.count, columnCount >= 2 else { return [] }

        var options: [TransformOption] = []
        var index = 1

        // 1. Standard Markdown Table
        let tableUnsorted = buildMarkdownTable(headerRow: matrix[0], dataRows: Array(matrix.dropFirst()), columnCount: columnCount)
        options.append(TransformOption(
            title: "Convert CSV/TSV to Markdown Table",
            detail: "Formatted GitHub Markdown table grid",
            shortcutKey: "\(index)",
            transformedContent: tableUnsorted
        ))
        index += 1

        // 2. Markdown Table with Sorted Rows (A-Z by Column 1)
        let sortedDataRows = Array(matrix.dropFirst()).sorted { r1, r2 in
            let col1 = r1.first ?? ""
            let col2 = r2.first ?? ""
            return col1.localizedStandardCompare(col2) == .orderedAscending
        }
        let tableSorted = buildMarkdownTable(headerRow: matrix[0], dataRows: sortedDataRows, columnCount: columnCount)
        if tableSorted != tableUnsorted {
            options.append(TransformOption(
                title: "Convert & Sort Table Rows (A-Z)",
                detail: "Markdown table with data rows sorted alphabetically by Column 1",
                shortcutKey: "\(index)",
                transformedContent: tableSorted
            ))
        }

        return options
    }

    private func buildMarkdownTable(headerRow: [String], dataRows: [[String]], columnCount: Int) -> String {
        var rows: [String] = []

        // Header Row
        let header = "| " + headerRow.joined(separator: " | ") + " |"
        rows.append(header)

        // Separator Row
        let separator = "| " + Array(repeating: "---", count: columnCount).joined(separator: " | ") + " |"
        rows.append(separator)

        // Data Rows
        for row in dataRows {
            let paddedRow = row + Array(repeating: "", count: max(0, columnCount - row.count))
            rows.append("| " + paddedRow.joined(separator: " | ") + " |")
        }

        return rows.joined(separator: "\n")
    }

    private func parseCSVLine(_ line: String, delimiter: Character) -> [String] {
        var fields: [String] = []
        var current = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == delimiter && !insideQuotes {
                fields.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current.trimmingCharacters(in: .whitespaces))
        return fields.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
    }
}
