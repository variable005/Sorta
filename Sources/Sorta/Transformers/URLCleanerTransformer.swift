import Foundation

public struct URLCleanerTransformer: TransformerProtocol {
    public var category: ClipCategory { .url }

    private let trackingParameters: Set<String> = [
        // Standard UTM
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "utm_id", "utm_source_platform",
        // Social Media & Ad Click IDs
        "fbclid", "gclid", "gclsrc", "dclid", "wbraid", "gbraid", "si", "ref", "ref_src", "ref_url",
        "ttclid", "twclid", "igshid", "mc_cid", "mc_eid", "yclid", "msclkid",
        // Email & Marketing Automation
        "_hsenc", "_hsmi", "mkt_tok", "trk", "trkcampaign", "sc_campaign", "sc_channel",
        // Platform Tracking
        "s_cid", "feature", "share_id", "spm", "source", "adgroupid", "keyword", "gad_source"
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

        // 1. Clean Tracking Parameters & Canonicalize
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

        // 2. Decode URL Percent-Encoding
        if let decoded = trimmed.removingPercentEncoding, decoded != trimmed {
            options.append(TransformOption(
                title: "Decode URL Percent-Encoding",
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

        // 4. Raw Canonical Copy
        options.append(TransformOption(
            title: "Copy Clean URL",
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
