import Foundation

public struct URLCleanerTransformer: TransformerProtocol {
    public var category: ClipCategory { .url }

    private let trackingParameters: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "fbclid", "gclid", "si", "ref", "mc_cid", "mc_eid", "yclid", "msclkid",
        "igshid", "_hsenc", "_hsmi", "mkt_tok"
    ]

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        return true
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed) else { return [] }

        var options: [TransformOption] = []
        var index = 1

        // 1. Cleaned URL
        if let queryItems = components.queryItems, !queryItems.isEmpty {
            let filteredItems = queryItems.filter { !trackingParameters.contains($0.name.lowercased()) }
            components.queryItems = filteredItems.isEmpty ? nil : filteredItems
            if let cleanURLString = components.url?.absoluteString, cleanURLString != trimmed {
                options.append(TransformOption(
                    title: "Clean Tracking Parameters",
                    detail: cleanURLString,
                    shortcutKey: "\(index)",
                    transformedContent: cleanURLString
                ))
                index += 1
            }
        }

        // 2. Decode URL Encoding
        if let decoded = trimmed.removingPercentEncoding, decoded != trimmed {
            options.append(TransformOption(
                title: "Decode URL Encoding",
                detail: decoded,
                shortcutKey: "\(index)",
                transformedContent: decoded
            ))
            index += 1
        }

        // 3. Extract Host / Domain
        if let host = components.host {
            options.append(TransformOption(
                title: "Extract Domain Host",
                detail: host,
                shortcutKey: "\(index)",
                transformedContent: host
            ))
            index += 1
        }

        // 4. Raw Copy
        options.append(TransformOption(
            title: "Original URL",
            detail: trimmed,
            shortcutKey: "\(index)",
            transformedContent: trimmed
        ))

        return options
    }
}
