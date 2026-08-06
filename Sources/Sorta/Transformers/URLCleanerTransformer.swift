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
        guard let components = getURLComponents(from: trimmed),
              let scheme = components.scheme,
              ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        return true
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = getURLComponents(from: trimmed) else { return [] }

        var options: [TransformOption] = []
        var index = 1

        // 1. Clean Tracking Parameters & Sort Remaining Parameters
        if let queryItems = components.queryItems, !queryItems.isEmpty {
            let filteredItems = queryItems.filter { !trackingParameters.contains($0.name.lowercased()) }
            let sortedFiltered = sortQueryItems(filteredItems)
            components.queryItems = sortedFiltered.isEmpty ? nil : sortedFiltered

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

        // 2. Sort Query Parameters (Canonical URL)
        var sortComponents = getURLComponents(from: trimmed) ?? components
        if let queryItems = sortComponents.queryItems, queryItems.count >= 2 {
            let sortedItems = sortQueryItems(queryItems)
            sortComponents.queryItems = sortedItems
            if let sortedURLString = sortComponents.url?.absoluteString, sortedURLString != trimmed {
                options.append(TransformOption(
                    title: "Sort Query Parameters (Canonical URL)",
                    detail: "Alphabetically sorts URL parameters",
                    shortcutKey: "\(index)",
                    transformedContent: sortedURLString
                ))
                index += 1
            }
        }

        // 3. Decode URL Encoding
        if let decoded = trimmed.removingPercentEncoding, decoded != trimmed {
            options.append(TransformOption(
                title: "Decode URL Encoding",
                detail: decoded,
                shortcutKey: "\(index)",
                transformedContent: decoded
            ))
            index += 1
        }

        // 4. Extract Host / Domain
        if let host = components.host {
            options.append(TransformOption(
                title: "Extract Domain Host",
                detail: host,
                shortcutKey: "\(index)",
                transformedContent: host
            ))
            index += 1
        }

        // 5. Raw Copy
        options.append(TransformOption(
            title: "Original URL",
            detail: trimmed,
            shortcutKey: "\(index)",
            transformedContent: trimmed
        ))

        return options
    }

    private func getURLComponents(from string: String) -> URLComponents? {
        if let comp = URLComponents(string: string) {
            return comp
        }
        if let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URLComponents(string: encoded)
        }
        return nil
    }

    private func sortQueryItems(_ items: [URLQueryItem]) -> [URLQueryItem] {
        return items.sorted { item1, item2 in
            if item1.name != item2.name {
                return item1.name.localizedStandardCompare(item2.name) == .orderedAscending
            }
            let val1 = item1.value ?? ""
            let val2 = item2.value ?? ""
            return val1.localizedStandardCompare(val2) == .orderedAscending
        }
    }
}
