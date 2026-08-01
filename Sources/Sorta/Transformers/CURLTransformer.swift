import Foundation

public struct CURLTransformer: TransformerProtocol {
    public var category: ClipCategory { .curl }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.lowercased().hasPrefix("curl ")
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsed = parseCURL(trimmed)

        var options: [TransformOption] = []
        var index = 1

        // 1. JS Fetch
        let fetchCode = generateFetch(parsed)
        options.append(TransformOption(
            title: "Convert to JavaScript fetch()",
            detail: "Modern async fetch snippet",
            shortcutKey: "\(index)",
            transformedContent: fetchCode
        ))
        index += 1

        // 2. Python Requests
        let pythonCode = generatePython(parsed)
        options.append(TransformOption(
            title: "Convert to Python requests",
            detail: "Python requests library code",
            shortcutKey: "\(index)",
            transformedContent: pythonCode
        ))
        index += 1

        // 3. Swift URLSession
        let swiftCode = generateSwift(parsed)
        options.append(TransformOption(
            title: "Convert to Swift URLSession",
            detail: "Native Swift async URLSession snippet",
            shortcutKey: "\(index)",
            transformedContent: swiftCode
        ))

        return options
    }

    private struct ParsedCURL {
        var url: String = "https://example.com"
        var method: String = "GET"
        var headers: [String: String] = [:]
        var body: String? = nil
    }

    private func parseCURL(_ curlString: String) -> ParsedCURL {
        var parsed = ParsedCURL()

        // Extract URL
        let tokens = curlString.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        for (idx, token) in tokens.enumerated() {
            let cleanToken = token.trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
            if cleanToken.hasPrefix("http://") || cleanToken.hasPrefix("https://") {
                parsed.url = cleanToken
            } else if (token == "-X" || token == "--request") && idx + 1 < tokens.count {
                parsed.method = tokens[idx + 1].trimmingCharacters(in: CharacterSet(charactersIn: "'\"")).uppercased()
            } else if (token == "-H" || token == "--header") && idx + 1 < tokens.count {
                let headerStr = tokens[idx + 1].trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
                let parts = headerStr.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    parsed.headers[parts[0]] = parts[1]
                }
            } else if (token == "-d" || token == "--data" || token == "--data-raw") && idx + 1 < tokens.count {
                parsed.body = tokens[idx + 1].trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
                if parsed.method == "GET" {
                    parsed.method = "POST"
                }
            }
        }
        return parsed
    }

    private func generateFetch(_ parsed: ParsedCURL) -> String {
        var opts: [String] = ["  method: '\(parsed.method)'"]
        if !parsed.headers.isEmpty {
            let headerLines = parsed.headers.map { "    '\($0.key)': '\($0.value)'" }.joined(separator: ",\n")
            opts.append("  headers: {\n\(headerLines)\n  }")
        }
        if let body = parsed.body {
            opts.append("  body: JSON.stringify(\(body))")
        }

        return """
        const response = await fetch('\(parsed.url)', {
        \(opts.joined(separator: ",\n"))
        });
        const data = await response.json();
        """
    }

    private func generatePython(_ parsed: ParsedCURL) -> String {
        var lines = ["import requests", ""]
        lines.append("url = '\(parsed.url)'")
        if !parsed.headers.isEmpty {
            let headerItems = parsed.headers.map { "    '\($0.key)': '\($0.value)'" }.joined(separator: ",\n")
            lines.append("headers = {\n\(headerItems)\n}")
        } else {
            lines.append("headers = {}")
        }

        let methodLower = parsed.method.lowercased()
        if let body = parsed.body {
            lines.append("payload = \(body)")
            lines.append("response = requests.\(methodLower)(url, headers=headers, json=payload)")
        } else {
            lines.append("response = requests.\(methodLower)(url, headers=headers)")
        }
        lines.append("print(response.json())")

        return lines.joined(separator: "\n")
    }

    private func generateSwift(_ parsed: ParsedCURL) -> String {
        return """
        guard let url = URL(string: "\(parsed.url)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "\(parsed.method)"
        \(parsed.headers.map { "request.addValue(\"\($0.value)\", forHTTPHeaderField: \"\($0.key)\")" }.joined(separator: "\n"))
        \(parsed.body != nil ? "request.httpBody = \"\(parsed.body!)\".data(using: .utf8)" : "")

        let (data, response) = try await URLSession.shared.data(for: request)
        """
    }
}
