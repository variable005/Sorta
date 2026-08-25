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
            // OPTIONAL SIDEBAR: History Drawer
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
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))

                    Divider()

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

                    // Sidebar Footer
                    HStack {
                        Text("\(viewModel.filteredHistory.count) clips")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Spacer()

                        if !watcher.history.isEmpty {
                            Button("Clear") {
                                watcher.clearHistory()
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .frame(width: 250)
                .transition(.move(edge: .leading).combined(with: .opacity))

                Divider()
            }

            // MAIN AREA: Native macOS Viewer
            VStack(spacing: 0) {
                if let item = viewModel.currentSelectedItem {
                    // Top Header Bar
                    HStack(spacing: 8) {
                        // Toggle Sidebar Button
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                viewModel.isSidebarVisible.toggle()
                            }
                        }) {
                            Image(systemName: viewModel.isSidebarVisible ? "sidebar.left" : "clock.arrow.circlepath")
                                .font(.system(size: 11))
                                .foregroundColor(viewModel.isSidebarVisible ? .primary : .secondary)
                                .frame(width: 26, height: 26)
                                .background(Color.white.opacity(viewModel.isSidebarVisible ? 0.15 : (viewModel.isHovering ? 0.08 : 0.0)))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)

                        // Category Icon
                        Image(systemName: item.category.systemImageName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)

                        Spacer(minLength: 12)

                        // Action Buttons (Reveals on Hover)
                        HStack(spacing: 6) {
                            // Copy Button
                            Button(action: {
                                viewModel.copyWithAnimation(item: item)
                            }) {
                                Image(systemName: viewModel.justCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 11, weight: viewModel.justCopied ? .bold : .regular))
                                    .foregroundColor(viewModel.justCopied ? .green : .secondary)
                                    .frame(width: 26, height: 26)
                                    .background(Color.white.opacity(viewModel.justCopied ? 0.18 : 0.08))
                                    .cornerRadius(6)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: viewModel.justCopied)
                            }
                            .buttonStyle(.plain)

                            // Paste Button
                            Button(action: {
                                watcher.pasteRawItem(item)
                                PanelManager.shared.hidePanel()
                            }) {
                                Image(systemName: "return")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 26, height: 26)
                                    .background(Color.white)
                                    .cornerRadius(6)
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

                    // Main Content View
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
                                // Single image preview (Draggable)
                                VStack(spacing: 14) {
                                    if let data = item.imageData, let nsImage = NSImage(data: data) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 380, maxHeight: 250)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                            )
                                            .onDrag {
                                                DragItemProviderHelper.createImageItemProvider(item: item)
                                            }
                                    }

                                    if let dims = item.imageDimensions {
                                        Text(dims)
                                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(20)
                            }
                        } else {
                            NativeTextContentView(item: item, watcher: watcher)
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
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No clipboard content")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: viewModel.isSidebarVisible ? 720 : 580, height: 420)
        .background(VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

/// Standard Native macOS Text Content Viewers
struct NativeTextContentView: View {
    let item: ClipItem
    let watcher: PasteboardWatcher

    var body: some View {
        VStack(spacing: 0) {
            switch item.category {
            case .color:
                NativeColorDetailView(rawContent: item.rawContent, watcher: watcher)
            case .timestamp:
                NativeTimestampDetailView(rawContent: item.rawContent)
            case .jwt:
                NativeJWTDetailView(rawContent: item.rawContent)
            case .json:
                NativeJSONDetailView(rawContent: item.rawContent)
            case .url:
                NativeURLDetailView(rawContent: item.rawContent)
            default:
                NativeStandardTextView(rawContent: item.rawContent, category: item.category)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

/// Standard Text View (Draggable)
struct NativeStandardTextView: View {
    let rawContent: String
    let category: ClipCategory

    var isMonospaced: Bool {
        category == .json || category == .curl || category == .jwt
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Text(rawContent)
                .font(.system(size: isMonospaced ? 12.5 : 13.5, weight: .regular, design: isMonospaced ? .monospaced : .default))
                .foregroundColor(.primary)
                .lineSpacing(isMonospaced ? 4 : 5)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrag {
            NSItemProvider(object: rawContent as NSString)
        }
    }
}

/// JSON View (2-Space Auto-Pretty-Printed, Draggable)
struct NativeJSONDetailView: View {
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
                .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrag {
            NSItemProvider(object: prettyJSON as NSString)
        }
    }
}

/// JWT Token View
struct NativeJWTDetailView: View {
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
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 2)

                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    Text(payload)
                        .font(.system(size: 12.5, weight: .regular, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onDrag {
                    NSItemProvider(object: payload as NSString)
                }
            }
        } else {
            NativeStandardTextView(rawContent: rawContent, category: .jwt)
        }
    }
}

/// Color Detail View
struct NativeColorDetailView: View {
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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: col.r, green: col.g, blue: col.b))
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                VStack(spacing: 6) {
                    NativeColorRow(label: "HEX", value: col.hex) { watcher.copyToClipboard(content: col.hex) }
                    NativeColorRow(label: "RGB", value: col.rgb) { watcher.copyToClipboard(content: col.rgb) }
                    NativeColorRow(label: "SwiftUI", value: String(format: "Color(red: %.2f, green: %.2f, blue: %.2f)", col.r, col.g, col.b)) {
                        watcher.copyToClipboard(content: String(format: "Color(red: %.3f, green: %.3f, blue: %.3f)", col.r, col.g, col.b))
                    }
                }
                .frame(maxWidth: 320)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
        } else {
            NativeStandardTextView(rawContent: rawContent, category: .color)
        }
    }
}

struct NativeColorRow: View {
    let label: String
    let value: String
    let onCopy: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 55, alignment: .leading)

            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
                .textSelection(.enabled)

            Spacer()

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.06))
        .cornerRadius(6)
    }
}

/// Timestamp Detail View
struct NativeTimestampDetailView: View {
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
                    .font(.system(size: 30))
                    .foregroundColor(.secondary)

                VStack(spacing: 4) {
                    Text(formattedDate(date))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(formattedTime(date))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Text("Relative: \(relativeTime(date))")
                        .font(.system(size: 10.5))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)

                    Text("Epoch: \(Int(date.timeIntervalSince1970))")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
        } else {
            NativeStandardTextView(rawContent: rawContent, category: .timestamp)
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

/// URL Detail View
struct NativeURLDetailView: View {
    let rawContent: String

    var urlComponents: URLComponents? {
        URLComponents(string: rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text(rawContent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
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
                                    .foregroundColor(.secondary)
                                Text(host)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(5)
                        }

                        if !comps.path.isEmpty && comps.path != "/" {
                            HStack(spacing: 4) {
                                Text("Path:")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text(comps.path)
                                    .font(.system(size: 10))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(5)
                        }
                    }

                    if let queryItems = comps.queryItems, !queryItems.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Query Parameters (\(queryItems.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)

                            VStack(spacing: 3) {
                                ForEach(queryItems, id: \.name) { q in
                                    HStack {
                                        Text(q.name)
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.primary.opacity(0.9))
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
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(4)
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
        .onDrag {
            NSItemProvider(object: rawContent as NSString)
        }
    }
}

/// Image Grid Card (Draggable)
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
                                .foregroundColor(.secondary)
                        )
                }

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)

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
                        isSelected ? Color.white : Color.white.opacity(0.15),
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
        .onDrag {
            DragItemProviderHelper.createImageItemProvider(item: item)
        }
    }
}

/// Helper for native macOS drag-and-drop item provider export
public enum DragItemProviderHelper {
    public static func createImageItemProvider(item: ClipItem) -> NSItemProvider {
        guard let data = item.imageData, let nsImage = NSImage(data: data) else {
            return NSItemProvider()
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Sorta_\(item.id.uuidString.prefix(8)).png"
        let fileURL = tempDir.appendingPathComponent(fileName)

        try? data.write(to: fileURL)

        let provider = NSItemProvider()

        // 1. Register as a file URL for Desktop/Finder/Folders/Mail
        provider.registerFileRepresentation(forTypeIdentifier: "public.png", fileOptions: .openInPlace, visibility: .all) { completion in
            completion(fileURL, true, nil)
            return nil
        }

        // 2. Register data representation for web browsers/Discord/Slack/Figma
        provider.registerDataRepresentation(forTypeIdentifier: "public.png", visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        // 3. Register NSImage object for native AppKit drop targets
        provider.registerObject(nsImage, visibility: .all)

        return provider
    }
}

/// Native macOS AppKit Visual Effect Blur
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
