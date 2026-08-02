import Foundation

public struct SQLTransformer: TransformerProtocol {
    public var category: ClipCategory { .sql }

    private let keywords = [
        "select", "from", "where", "insert into", "values", "update", "set",
        "delete from", "inner join", "left join", "right join", "outer join",
        "group by", "order by", "having", "limit", "offset", "create table"
    ]

    public init() {}

    public func detect(content: String) -> Bool {
        let lower = content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return lower.hasPrefix("select ") || lower.hasPrefix("insert into ") || lower.hasPrefix("update ") || lower.hasPrefix("delete from ")
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let formatted = prettifySQL(trimmed)

        return [
            TransformOption(
                title: "Prettify & Format SQL Query",
                detail: "Uppercase keywords with clause linebreaks",
                shortcutKey: "1",
                transformedContent: formatted
            )
        ]
    }

    private func prettifySQL(_ sql: String) -> String {
        var result = sql
        for kw in keywords {
            let pattern = "\\b\(kw)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: result.utf16.count)
                let upperKW = kw.uppercased()
                if ["FROM", "WHERE", "INNER JOIN", "LEFT JOIN", "RIGHT JOIN", "GROUP BY", "ORDER BY", "HAVING"].contains(upperKW) {
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "\n\(upperKW)")
                } else {
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: upperKW)
                }
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
