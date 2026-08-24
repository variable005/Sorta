import Foundation

public struct CURLTransformer: TransformerProtocol {
    public var category: ClipCategory { .curl }

    public init() {}

    public func detect(content: String) -> Bool {
        let trimmed = content
            .replacingOccurrences(of: "\\\n", with: " ")
            .replacingOccurrences(of: "\\\r\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.lowercased().hasPrefix("curl ")
    }

    public func transform(content: String) -> [TransformOption] {
        let trimmed = content
            .replacingOccurrences(of: "\\\n", with: " ")
            .replacingOccurrences(of: "\\\r\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let parsed = parseCURL(trimmed)

        var options: [TransformOption] = []
        var index = 1

        // 1. JS Fetch
        let fetchCode = generateFetch(parsed)
        options.append(TransformOption(
            title: "JavaScript fetch()",
            detail: "Modern async/await fetch snippet",
            shortcutKey: "\(index)",
            transformedContent: fetchCode
        ))
        index += 1

        // 2. Python Requests
        let pythonCode = generatePython(parsed)
        options.append(TransformOption(
            title: "Python requests",
            detail: "Python requests library code",
            shortcutKey: "\(index)",
            transformedContent: pythonCode
        ))
        index += 1

        // 3. Swift URLSession
        let swiftCode = generateSwift(parsed)
        options.append(TransformOption(
            title: "Swift URLSession",
            detail: "Native Swift async URLSession request",
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
        let tokens = tokenize(curlString)

        var i = 0
        while i < tokens.count {
            let token = tokens[i]

            if (token == "-X" || token == "--request") && i + 1 < tokens.count {
                parsed.method = tokens[i + 1].uppercased()
                i += 2
                continue
            }

            if (token == "-H" || token == "--header") && i + 1 < tokens.count {
                let headerStr = tokens[i + 1]
                let parts = headerStr.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    parsed.headers[parts[0]] = parts[1]
                }
                i += 2
                continue
            }

            if (token == "-d" || token == "--data" || token == "--data-raw" || token == "--data-binary") && i + 1 < tokens.count {
                parsed.body = tokens[i + 1]
                if parsed.method == "GET" {
                    parsed.method = "POST"
                }
                i += 2
                continue
            }

            if (token.hasPrefix("http://") || token.hasPrefix("https://")) && !token.hasPrefix("-") {
                parsed.url = token
            }

            i += 1
        }

        return parsed
    }

    private func tokenize(_ command: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var inSingleQuote = false
        var inDoubleQuote = false
        var isEscaped = false

        for char in command {
            if isEscaped {
                current.append(char)
                isEscaped = false
                continue
            }

            if char == "\\" && !inSingleQuote {
                isEscaped = true
                continue
            }

            if char == "'" && !inDoubleQuote {
                inSingleQuote.toggle()
                continue
            }

            if char == "\"" && !inSingleQuote {
                inDoubleQuote.toggle()
                continue
            }

            if (char.isWhitespace || char.isNewline) && !inSingleQuote && !inDoubleQuote {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                continue
            }

            current.append(char)
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }

    private func sortedHeaderKeys(_ headers: [String: String]) -> [String] {
        return headers.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private func generateFetch(_ parsed: ParsedCURL) -> String {
        var opts: [String] = ["  method: '\(parsed.method)'"]
        if !parsed.headers.isEmpty {
            let sortedKeys = sortedHeaderKeys(parsed.headers)
            let headerLines = sortedKeys.map { key in "    '\(key)': '\(parsed.headers[key]!)'" }.joined(separator: ",\n")
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
            let sortedKeys = sortedHeaderKeys(parsed.headers)
            let headerItems = sortedKeys.map { key in "    '\(key)': '\(parsed.headers[key]!)'" }.joined(separator: ",\n")
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
        let sortedKeys = sortedHeaderKeys(parsed.headers)
        let headerLines = sortedKeys.map { key in "request.addValue(\"\(parsed.headers[key]!)\", forHTTPHeaderField: \"\(key)\")" }.joined(separator: "\n")

        return """
        guard let url = URL(string: "\(parsed.url)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "\(parsed.method)"
        \(headerLines)
        \(parsed.body != nil ? "request.httpBody = \"\(parsed.body!)\".data(using: .utf8)" : "")

        let (data, response) = try await URLSession.shared.data(for: request)
        """
    }
}
