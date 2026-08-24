import SwiftUI
import AppKit

public struct SortaHUDView: View {
    @ObservedObject var watcher: PasteboardWatcher
    @StateObject private var viewModel: HUDViewModel

    public init(watcher: PasteboardWatcher) {
        self.watcher = watcher
        self._viewModel = StateObject(wrappedValue: HUDViewModel(watcher: watcher))
    }

    private var imageHistory: [ClipItem] {
        watcher.history.filter { $0.isImage }
    }

    public var body: some View {
        HStack(spacing: 0) {
            // OPTIONAL SIDEBAR: Hidden by default, toggled with Tab / Cmd+H or Hover Button
            if viewModel.isSidebarVisible {
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))

                        TextField("Search...", text: $viewModel.searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.04))

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // History List
                    HistoryListView(
                        viewModel: viewModel,
                        watcher: watcher,
                        onSelect: { _ in },
                        onDoubleClick: { selectedItem in
                            watcher.pasteRawItem(selectedItem)
                            PanelManager.shared.hidePanel()
                        }
                    )

                    Spacer(minLength: 0)

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // Sidebar Footer
                    HStack {
                        Text("\(viewModel.filteredHistory.count) clips")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Spacer()

                        if !watcher.history.isEmpty {
                            Button("Clear") {
                                watcher.clearHistory(preservePinned: true)
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.02))
                }
                .frame(width: 250)
                .transition(.move(edge: .leading).combined(with: .opacity))

                Divider()
                    .background(Color.white.opacity(0.12))
            }

            // MAIN AREA: Full Content Viewer
            VStack(spacing: 0) {
                if let item = viewModel.currentSelectedItem {
                    // Top Header Bar
                    HStack(spacing: 8) {
                        // Toggle Sidebar Button (Hover Only or Active)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.isSidebarVisible.toggle()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isSidebarVisible ? "sidebar.left" : "clock.arrow.circlepath")
                                    .font(.system(size: 11))
                                if !viewModel.isSidebarVisible && viewModel.isHovering {
                                    Text("History")
                                        .font(.system(size: 11, weight: .medium))
                                        .lineLimit(1)
                                }
                            }
                            .foregroundColor(viewModel.isSidebarVisible ? .primary : .secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(viewModel.isSidebarVisible ? 0.12 : (viewModel.isHovering ? 0.08 : 0.0)))
                            .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                        .fixedSize()

                        // Category Badge
                        HStack(spacing: 5) {
                            Image(systemName: item.category.systemImageName)
                                .foregroundColor(.secondary)
                                .font(.system(size: 11, weight: .semibold))

                            Text(item.isImage ? "Images (\(imageHistory.count))" : item.category.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(5)
                        .fixedSize()

                        // Stats
                        if item.isImage {
                            Text(formatImageStats(item))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        } else {
                            Text("\(item.rawContent.count) chars • \(item.rawContent.components(separatedBy: .newlines).count) lines • \(countWords(item.rawContent)) words")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }

                        Spacer(minLength: 12)

                        // Minimal Action Options (Always strictly single line with fixed width)
                        HStack(spacing: 6) {
                            // Star / Pin
                            Button(action: {
                                watcher.togglePin(item: item)
                            }) {
                                Image(systemName: item.isPinned ? "star.fill" : "star")
                                    .font(.system(size: 11))
                                    .foregroundColor(item.isPinned ? .yellow : .secondary)
                                    .frame(width: 24, height: 24)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(5)
                            }
                            .buttonStyle(.plain)

                            // Copy
                            Button(action: {
                                watcher.copyItemToClipboard(item)
                                PanelManager.shared.hidePanel()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 10))
                                    Text("Copy")
                                        .font(.system(size: 11, weight: .medium))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(5)
                            }
                            .buttonStyle(.plain)

                            // Paste
                            Button(action: {
                                watcher.pasteRawItem(item)
                                PanelManager.shared.hidePanel()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "return")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("Paste")
                                        .font(.system(size: 11, weight: .bold))
                                        .lineLimit(1)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(5)
                            }
                            .buttonStyle(.plain)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .opacity(viewModel.isHovering ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.15), value: viewModel.isHovering)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.02))

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // FULL CONTENT BODY (SMART FORMATTED VIEWER)
                    if item.isImage {
                        if imageHistory.count > 1 {
                            // Responsive Multi-Cell Image Grid (Strictly bounded 2-columns)
                            ScrollView(.vertical, showsIndicators: true) {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                    ForEach(imageHistory) { imgItem in
                                        ImageGridCard(
                                            item: imgItem,
                                            isSelected: imgItem.id == item.id,
                                            onSelect: {
                                                if let idx = viewModel.filteredHistory.firstIndex(where: { $0.id == imgItem.id }) {
                                                    viewModel.selectedIndex = idx
                                                }
                                            },
                                            onDoubleClick: {
                                                watcher.pasteRawItem(imgItem)
                                                PanelManager.shared.hidePanel()
                                            },
                                            onTogglePin: {
                                                watcher.togglePin(item: imgItem)
                                            }
                                        )
                                    }
                                }
                                .padding(14)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.18))
                        } else {
                            // Single Image View (Shrunk, centered modern card)
                            VStack(spacing: 12) {
                                if let data = item.imageData, let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 360, maxHeight: 230)
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.45), radius: 12, x: 0, y: 6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                                        )
                                }

                                // Dimension & size pill
                                HStack(spacing: 6) {
                                    if let dims = item.imageDimensions {
                                        Text(dims)
                                            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.9))
                                            .lineLimit(1)
                                    }
                                    if let count = item.imageData?.count {
                                        Text("•")
                                            .font(.system(size: 8))
                                            .foregroundColor(.secondary)
                                        Text("\(count / 1024) KB")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(6)
                                .fixedSize()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(20)
                            .background(Color.black.opacity(0.18))
                        }
                    } else {
                        // SMART TEXT FORMATTER
                        SmartTextFormatterView(item: item, watcher: watcher)
                    }

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // Subtle Minimal Footer
                    HStack {
                        Text(formattedFullDate(item.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.8))
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: 10) {
                            KeyboardBadge(key: "↵", label: "Paste")
                            KeyboardBadge(key: "⌘C", label: "Copy")
                            KeyboardBadge(key: "Tab", label: "History")
                            KeyboardBadge(key: "esc", label: "Close")
                        }
                        .fixedSize()
                        .opacity(viewModel.isHovering ? 1.0 : 0.4)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.015))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text("No clipboard content")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: viewModel.isSidebarVisible ? 720 : 580, height: 440)
        .background(
            ZStack {
                Color(red: 0.11, green: 0.11, blue: 0.12).opacity(0.96)
                VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.isHovering = hovering
            }
        }
        .background(
            KeyEventHandlerView { event in
                return viewModel.handleKeyDown(event: event)
            }
        )
    }

    private func countWords(_ string: String) -> Int {
        let words = string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return words.count
    }

    private func formatImageStats(_ item: ClipItem) -> String {
        var parts: [String] = []
        if let dims = item.imageDimensions {
            parts.append(dims)
        }
        if let count = item.imageData?.count {
            if count > 1024 * 1024 {
                parts.append(String(format: "%.1f MB", Double(count) / (1024.0 * 1024.0)))
            } else {
                parts.append("\(count / 1024) KB")
            }
        }
        return parts.joined(separator: " • ")
    }

    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Smart Context-Aware Formatter for various clipboard types
struct SmartTextFormatterView: View {
    let item: ClipItem
    let watcher: PasteboardWatcher

    var body: some View {
        switch item.category {
        case .color:
            ColorDetailView(rawContent: item.rawContent, watcher: watcher)
        case .timestamp:
            TimestampDetailView(rawContent: item.rawContent)
        case .jwt:
            JWTDetailView(rawContent: item.rawContent)
        case .json:
            JSONCodeViewer(rawContent: item.rawContent)
        case .url:
            URLDetailView(rawContent: item.rawContent)
        default:
            StandardTextViewer(rawContent: item.rawContent, category: item.category)
        }
    }
}

/// Rich Visual Color Swatch & Code Formatter
struct ColorDetailView: View {
    let rawContent: String
    let watcher: PasteboardWatcher

    var parsedColor: (r: Double, g: Double, b: Double, hex: String, rgb: String)? {
        let trimmed = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
        var clean = trimmed
        if clean.hasPrefix("#") { clean.removeFirst() }

        if clean.count == 6, let hexNum = UInt32(clean, radix: 16) {
            let r = Double((hexNum >> 16) & 0xFF) / 255.0
            let g = Double((hexNum >> 8) & 0xFF) / 255.0
            let b = Double(hexNum & 0xFF) / 255.0
            let hexStr = "#\(clean.uppercased())"
            let rgbStr = "rgb(\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255)))"
            return (r, g, b, hexStr, rgbStr)
        }
        return nil
    }

    var body: some View {
        if let col = parsedColor {
            VStack(spacing: 16) {
                // Color Tile
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: col.r, green: col.g, blue: col.b))
                    .frame(width: 90, height: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)

                // Color Details
                VStack(spacing: 8) {
                    ColorRow(label: "HEX", value: col.hex) { watcher.copyToClipboard(content: col.hex) }
                    ColorRow(label: "RGB", value: col.rgb) { watcher.copyToClipboard(content: col.rgb) }
                    ColorRow(label: "SwiftUI", value: String(format: "Color(red: %.2f, green: %.2f, blue: %.2f)", col.r, col.g, col.b)) {
                        watcher.copyToClipboard(content: String(format: "Color(red: %.3f, green: %.3f, blue: %.3f)", col.r, col.g, col.b))
                    }
                }
                .frame(maxWidth: 340)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)
        } else {
            StandardTextViewer(rawContent: rawContent, category: .color)
        }
    }
}

struct ColorRow: View {
    let label: String
    let value: String
    let onCopy: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
                .textSelection(.enabled)

            Spacer()

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.04))
        .cornerRadius(6)
    }
}

/// Formatted Date & Timestamp Viewer
struct TimestampDetailView: View {
    let rawContent: String

    var parsedDate: Date? {
        let trimmed = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if let ts = Double(trimmed) {
            let seconds = ts > 100_000_000_000 ? ts / 1000.0 : ts
            return Date(timeIntervalSince1970: seconds)
        }
        let iso = ISO8601DateFormatter()
        return iso.date(from: trimmed)
    }

    var body: some View {
        if let date = parsedDate {
            VStack(spacing: 14) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)

                VStack(spacing: 6) {
                    Text(formattedDate(date, style: .full))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(formattedTime(date))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white.opacity(0.85))
                }

                HStack(spacing: 10) {
                    PillBadge(label: "Relative", value: relativeTime(date))
                    PillBadge(label: "Epoch", value: "\(Int(date.timeIntervalSince1970))")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)
        } else {
            StandardTextViewer(rawContent: rawContent, category: .timestamp)
        }
    }

    private func formattedDate(_ date: Date, style: DateFormatter.Style) -> String {
        let f = DateFormatter()
        f.dateStyle = style
        return f.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.timeZone = .current
        return f.string(from: date)
    }

    private func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }
}

struct PillBadge: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.06))
        .cornerRadius(6)
    }
}

/// Decoded JWT Viewer with Claims Formatting
struct JWTDetailView: View {
    let rawContent: String

    var decodedPayload: String? {
        let parts = rawContent.split(separator: ".")
        guard parts.count == 3 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: pretty, encoding: .utf8) else {
            return nil
        }
        return str
    }

    var body: some View {
        if let payload = decodedPayload {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Decoded JWT Payload")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                JSONCodeViewer(rawContent: payload)
            }
        } else {
            StandardTextViewer(rawContent: rawContent, category: .jwt)
        }
    }
}

/// Formatted JSON Code Viewer with Line Numbers
struct JSONCodeViewer: View {
    let rawContent: String

    var formattedJSONLines: [String] {
        let trimmed = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = trimmed.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
           let prettyStr = String(data: prettyData, encoding: .utf8) {
            return prettyStr.components(separatedBy: .newlines)
        }
        return rawContent.components(separatedBy: .newlines)
    }

    var body: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            HStack(alignment: .top, spacing: 12) {
                // Line Numbers Gutter
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(1...max(1, formattedJSONLines.count), id: \.self) { lineNum in
                        Text("\(lineNum)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary.opacity(0.4))
                    }
                }
                .padding(.trailing, 4)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 1),
                    alignment: .trailing
                )

                // Formatted Code Body
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(formattedJSONLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.white.opacity(0.95))
                    }
                }
            }
            .textSelection(.enabled)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.20))
    }
}

/// Clean URL Inspector
struct URLDetailView: View {
    let rawContent: String

    var urlComponents: URLComponents? {
        URLComponents(string: rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                // Main URL String
                Text(rawContent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .textSelection(.enabled)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(8)

                if let comps = urlComponents {
                    // Host & Path Badges
                    HStack(spacing: 8) {
                        if let host = comps.host {
                            PillBadge(label: "Host", value: host)
                        }
                        if !comps.path.isEmpty && comps.path != "/" {
                            PillBadge(label: "Path", value: comps.path)
                        }
                    }

                    // Query Parameters List
                    if let queryItems = comps.queryItems, !queryItems.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Query Parameters (\(queryItems.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)

                            VStack(spacing: 3) {
                                ForEach(queryItems, id: \.name) { q in
                                    HStack {
                                        Text(q.name)
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.8))
                                            .frame(minWidth: 70, alignment: .leading)

                                        Text(q.value ?? "")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(5)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Standard High-Contrast Text Viewer with Line Numbers for multi-line content
struct StandardTextViewer: View {
    let rawContent: String
    let category: ClipCategory

    var lines: [String] {
        rawContent.components(separatedBy: .newlines)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if lines.count > 2 {
                // Multi-line code / list viewer with subtle line numbers
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(1...lines.count, id: \.self) { lineNum in
                            Text("\(lineNum)")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary.opacity(0.35))
                        }
                    }
                    .padding(.trailing, 4)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 1),
                        alignment: .trailing
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            Text(line.isEmpty ? " " : line)
                                .font(.system(size: 12.5, design: fontDesignForCategory(category)))
                                .foregroundColor(.white.opacity(0.95))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .textSelection(.enabled)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                // Single/few line standard comfortable text
                Text(rawContent)
                    .font(.system(size: 13.5, design: fontDesignForCategory(category)))
                    .foregroundColor(.white.opacity(0.95))
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func fontDesignForCategory(_ category: ClipCategory) -> Font.Design {
        switch category {
        case .json, .curl, .jwt, .sort:
            return .monospaced
        default:
            return .default
        }
    }
}

/// Modern Image Grid Card with strictly bounded aspect-fill rendering
struct ImageGridCard: View {
    let item: ClipItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void
    let onTogglePin: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .bottomLeading) {
                if let data = item.imageData, let img = NSImage(data: data) {
                    Color.clear
                        .frame(height: 120)
                        .overlay(
                            Image(nsImage: img)
                                .resizable()
                                .scaledToFill()
                        )
                        .clipped()
                        .background(Color.white.opacity(0.04))
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        )
                }

                // Dark gradient overlay at bottom
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 34)

                // Info overlay
                HStack(spacing: 4) {
                    if let dims = item.imageDimensions {
                        Text(dims)
                            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Spacer()

                    if item.isPinned {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8.5))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onDoubleClick()
        })
    }
}

struct KeyboardBadge: View {
    let key: String
    let label: String

    var body: some View {
        HStack(spacing: 3) {
            Text(key)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .padding(.horizontal, 4)
                .padding(.vertical, 1.5)
                .background(Color.white.opacity(0.10))
                .cornerRadius(3)
                .foregroundColor(.primary.opacity(0.9))

            Text(label)
                .font(.system(size: 9.5))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .fixedSize()
    }
}

/// Native macOS AppKit Visual Effect Blur for clean backdrop
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

/// Helper NSView to intercept key events cleanly in the HUD
struct KeyEventHandlerView: NSViewRepresentable {
    let onKeyDown: (NSEvent) -> Bool

    func makeNSView(context: Context) -> KeyInterceptingView {
        let view = KeyInterceptingView()
        view.onKeyDown = onKeyDown
        return view
    }

    func updateNSView(_ nsView: KeyInterceptingView, context: Context) {
        nsView.onKeyDown = onKeyDown
    }

    class KeyInterceptingView: NSView {
        var onKeyDown: ((NSEvent) -> Bool)?
        private var monitor: Any?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if window != nil && monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                    guard let self = self, let handler = self.onKeyDown else { return event }
                    if handler(event) {
                        return nil // Handled!
                    }
                    return event
                }
            } else if window == nil && monitor != nil {
                if let m = monitor {
                    NSEvent.removeMonitor(m)
                    monitor = nil
                }
            }
        }

        deinit {
            if let m = monitor {
                NSEvent.removeMonitor(m)
            }
        }
    }
}
