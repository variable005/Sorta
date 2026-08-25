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
            // OPTIONAL SIDEBAR: Crystal Glass History Drawer
            if viewModel.isSidebarVisible {
                VStack(spacing: 0) {
                    // Search Bar Lens
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 12))

                        TextField("Search...", text: $viewModel.searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .foregroundColor(.white)

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))

                    Divider()
                        .background(Color.white.opacity(0.15))

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
                        .background(Color.white.opacity(0.15))

                    // Sidebar Footer
                    HStack {
                        Text("\(viewModel.filteredHistory.count) clips")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))

                        Spacer()

                        if !watcher.history.isEmpty {
                            Button("Clear") {
                                watcher.clearHistory()
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.04))
                }
                .frame(width: 250)
                .transition(.move(edge: .leading).combined(with: .opacity))

                Divider()
                    .background(Color.white.opacity(0.18))
            }

            // MAIN AREA: Ultra-Clear Liquid Glass Canvas
            VStack(spacing: 0) {
                if let item = viewModel.currentSelectedItem {
                    // Floating Liquid Glass Header Controls
                    HStack(spacing: 8) {
                        // Toggle Sidebar Glass Lens
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                viewModel.isSidebarVisible.toggle()
                            }
                        }) {
                            Image(systemName: viewModel.isSidebarVisible ? "sidebar.left" : "clock.arrow.circlepath")
                                .font(.system(size: 11))
                                .foregroundColor(viewModel.isSidebarVisible ? .white : .white.opacity(0.85))
                                .frame(width: 28, height: 28)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(viewModel.isSidebarVisible ? 0.30 : 0.16),
                                            Color.white.opacity(viewModel.isSidebarVisible ? 0.15 : 0.06)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(Color.white.opacity(0.30), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        // Category Type Lens
                        Image(systemName: item.category.systemImageName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.06)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
                            )

                        Spacer(minLength: 12)

                        // Action Lenses (Reveals on Hover)
                        HStack(spacing: 6) {
                            // Copy Lens Button
                            Button(action: {
                                viewModel.copyWithAnimation(item: item)
                            }) {
                                Image(systemName: viewModel.justCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 11, weight: viewModel.justCopied ? .bold : .regular))
                                    .foregroundColor(viewModel.justCopied ? .green : .white)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(viewModel.justCopied ? 0.35 : 0.20),
                                                Color.white.opacity(viewModel.justCopied ? 0.18 : 0.08)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(7)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color.white.opacity(viewModel.justCopied ? 0.50 : 0.30), lineWidth: 1)
                                    )
                                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: viewModel.justCopied)
                            }
                            .buttonStyle(.plain)

                            // Paste Lens Button
                            Button(action: {
                                watcher.pasteRawItem(item)
                                PanelManager.shared.hidePanel()
                            }) {
                                Image(systemName: "return")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color.white,
                                                Color.white.opacity(0.92)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(7)
                                    .shadow(color: Color.white.opacity(0.40), radius: 6, x: 0, y: 1)
                            }
                            .buttonStyle(.plain)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .opacity(viewModel.isHovering ? 1.0 : 0.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.85), value: viewModel.isHovering)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    Divider()
                        .background(Color.white.opacity(0.12))

                    // Direct Transparent Content
                    VStack {
                        if item.isImage {
                            if imageHistory.count > 1 {
                                // Multi-image grid
                                ScrollView(.vertical, showsIndicators: true) {
                                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                        ForEach(imageHistory) { imgItem in
                                            ImageGridCard(
                                                item: imgItem,
                                                isSelected: imgItem.id == item.id,
                                                onSelect: {
                                                    if let idx = viewModel.filteredHistory.firstIndex(where: { $0.id == imgItem.id }) {
                                                        withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) {
                                                            viewModel.selectedIndex = idx
                                                        }
                                                    }
                                                },
                                                onDoubleClick: {
                                                    watcher.pasteRawItem(imgItem)
                                                    PanelManager.shared.hidePanel()
                                                }
                                            )
                                        }
                                    }
                                    .padding(16)
                                }
                            } else {
                                // Single image preview
                                VStack(spacing: 14) {
                                    if let data = item.imageData, let nsImage = NSImage(data: data) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 380, maxHeight: 250)
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.40), radius: 18, x: 0, y: 8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [Color.white.opacity(0.45), Color.white.opacity(0.15)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1.2
                                                    )
                                            )
                                    }

                                    if let dims = item.imageDimensions {
                                        Text(dims)
                                            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.20), Color.white.opacity(0.08)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
                                            )
                                            .fixedSize()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(20)
                            }
                        } else {
                            // Fluid Liquid Glass Text View
                            LiquidGlassTextContent(item: item, watcher: watcher)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(item.id)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.12), value: item.id)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No clipboard content")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: viewModel.isSidebarVisible ? 720 : 580, height: 420)
        .background(
            ZStack {
                // High-transparency crystal glass visual effect
                VisualEffectBlur(material: .underWindowBackground, blendingMode: .behindWindow)

                // Refractive Glass Specular Sheen (Diagonal ambient light beam)
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.04),
                        Color.clear,
                        Color.white.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .overlay(
            // Prismatic Specular Glass Bevel
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.60),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) {
                viewModel.isHovering = hovering
            }
        }
        .background(
            KeyEventHandlerView { event in
                return viewModel.handleKeyDown(event: event)
            }
        )
    }
}

/// Content Views floating naturally on the Liquid Glass canvas
struct LiquidGlassTextContent: View {
    let item: ClipItem
    let watcher: PasteboardWatcher

    var body: some View {
        VStack(spacing: 0) {
            switch item.category {
            case .color:
                ColorDetailGlassView(rawContent: item.rawContent, watcher: watcher)
            case .timestamp:
                TimestampDetailGlassView(rawContent: item.rawContent)
            case .jwt:
                JWTDetailGlassView(rawContent: item.rawContent)
            case .json:
                JSONDetailGlassView(rawContent: item.rawContent)
            case .url:
                URLDetailGlassView(rawContent: item.rawContent)
            default:
                StandardTextGlassView(rawContent: item.rawContent, category: item.category)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

/// Standard Text floating directly on Liquid Glass
struct StandardTextGlassView: View {
    let rawContent: String
    let category: ClipCategory

    var isMonospaced: Bool {
        category == .json || category == .curl || category == .jwt
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Text(rawContent)
                .font(.system(size: isMonospaced ? 13 : 14, weight: .regular, design: isMonospaced ? .monospaced : .default))
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                .lineSpacing(isMonospaced ? 4 : 5)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// JSON Card (Formatted on Liquid Glass)
struct JSONDetailGlassView: View {
    let rawContent: String

    var prettyJSON: String {
        let trimmed = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = trimmed.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: prettyData, encoding: .utf8) {
            return str
        }
        return rawContent
    }

    var body: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            Text(prettyJSON)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// JWT Token View
struct JWTDetailGlassView: View {
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Decoded Claims")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 2)

                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    Text(payload)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(Color.white)
                        .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                        .lineSpacing(4)
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            StandardTextGlassView(rawContent: rawContent, category: .jwt)
        }
    }
}

/// Color Detail View
struct ColorDetailGlassView: View {
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
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: col.r, green: col.g, blue: col.b))
                    .frame(width: 84, height: 84)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.60), Color.white.opacity(0.20)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)

                VStack(spacing: 8) {
                    ColorGlassRow(label: "HEX", value: col.hex) { watcher.copyToClipboard(content: col.hex) }
                    ColorGlassRow(label: "RGB", value: col.rgb) { watcher.copyToClipboard(content: col.rgb) }
                    ColorGlassRow(label: "SwiftUI", value: String(format: "Color(red: %.2f, green: %.2f, blue: %.2f)", col.r, col.g, col.b)) {
                        watcher.copyToClipboard(content: String(format: "Color(red: %.3f, green: %.3f, blue: %.3f)", col.r, col.g, col.b))
                    }
                }
                .frame(maxWidth: 320)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
        } else {
            StandardTextGlassView(rawContent: rawContent, category: .color)
        }
    }
}

struct ColorGlassRow: View {
    let label: String
    let value: String
    let onCopy: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 55, alignment: .leading)

            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
                .textSelection(.enabled)

            Spacer()

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.white.opacity(0.16))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.16), Color.white.opacity(0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.24), lineWidth: 0.8)
        )
    }
}

/// Timestamp View
struct TimestampDetailGlassView: View {
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
                    .foregroundColor(.white.opacity(0.9))

                VStack(spacing: 5) {
                    Text(formattedDate(date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(formattedTime(date))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white.opacity(0.92))
                }

                HStack(spacing: 8) {
                    Text("Relative: \(relativeTime(date))")
                        .font(.system(size: 10.5))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.07)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.26), lineWidth: 0.8)
                        )

                    Text("Epoch: \(Int(date.timeIntervalSince1970))")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.07)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.26), lineWidth: 0.8)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
        } else {
            StandardTextGlassView(rawContent: rawContent, category: .timestamp)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .medium
        return f.string(from: date)
    }

    private func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }
}

/// URL Detail View with sheer crystal lenses
struct URLDetailGlassView: View {
    let rawContent: String

    var urlComponents: URLComponents? {
        URLComponents(string: rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 14) {
                // Pure clean URL text floating on glass
                Text(rawContent)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                    .lineSpacing(4)
                    .textSelection(.enabled)
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let comps = urlComponents {
                    HStack(spacing: 8) {
                        if let host = comps.host {
                            HStack(spacing: 4) {
                                Text("Host:")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(host)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.06)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.24), lineWidth: 0.8)
                            )
                        }

                        if !comps.path.isEmpty && comps.path != "/" {
                            HStack(spacing: 4) {
                                Text("Path:")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(comps.path)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.06)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.24), lineWidth: 0.8)
                            )
                        }
                    }

                    if let queryItems = comps.queryItems, !queryItems.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Query Parameters (\(queryItems.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.85))

                            VStack(spacing: 4) {
                                ForEach(queryItems, id: \.name) { q in
                                    HStack {
                                        Text(q.name)
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.95))
                                            .frame(minWidth: 70, alignment: .leading)

                                        Text(q.value ?? "")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(1)
                                            .truncationMode(.middle)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
                                    )
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Image Grid Card
struct ImageGridCard: View {
    let item: ClipItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void

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
                                .foregroundColor(.white.opacity(0.6))
                        )
                }

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.80)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 34)

                HStack(spacing: 4) {
                    if let dims = item.imageDimensions {
                        Text(dims)
                            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.white : Color.white.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.85), value: isSelected)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onDoubleClick()
        })
    }
}

/// Native macOS AppKit Visual Effect Blur with ultra-clear underWindowBackground
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
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
