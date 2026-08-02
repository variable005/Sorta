import Foundation

public struct MarkdownTableTransformer: TransformerProtocol {
    public var category: ClipCategory { .markdownTable }

    public init() {}

    public func detect(content: String) -> Bool {
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard lines.count >= 2 else { return false }

        let firstLineCommas = lines[0].split(separator: ",").count
        let firstLineTabs = lines[0].split(separator: "\t").count

        return (firstLineCommas >= 2 && lines[1].split(separator: ",").count == firstLineCommas) ||
               (firstLineTabs >= 2 && lines[1].split(separator: "\t").count == firstLineTabs)
    }

    public func transform(content: String) -> [TransformOption] {
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard lines.count >= 2 else { return [] }

        let isTabDelimited = lines[0].contains("\t")
        let delimiter: Character = isTabDelimited ? "\t" : ","

        let matrix = lines.map { line in
            line.split(separator: delimiter, omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespaces) }
        }

        guard let columnCount = matrix.first?.count, columnCount >= 2 else { return [] }

        var markdownRows: [String] = []

        // Header Row
        let header = "| " + matrix[0].joined(separator: " | ") + " |"
        markdownRows.append(header)

        // Separator Row
        let separator = "| " + Array(repeating: "---", count: columnCount).joined(separator: " | ") + " |"
        markdownRows.append(separator)

        // Data Rows
        for row in matrix.dropFirst() {
            let paddedRow = row + Array(repeating: "", count: max(0, columnCount - row.count))
            markdownRows.append("| " + paddedRow.joined(separator: " | ") + " |")
        }

        let markdownTable = markdownRows.joined(separator: "\n")

        return [
            TransformOption(
                title: "Convert CSV/TSV to Markdown Table",
                detail: "Formatted GitHub Markdown table grid",
                shortcutKey: "1",
                transformedContent: markdownTable
            )
        ]
    }
}
