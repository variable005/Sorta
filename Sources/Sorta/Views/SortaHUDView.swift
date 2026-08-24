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
                                }
                            }
                            .foregroundColor(viewModel.isSidebarVisible ? .primary : .secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(viewModel.isSidebarVisible ? 0.12 : (viewModel.isHovering ? 0.08 : 0.0)))
                            .cornerRadius(5)
                        }
                        .buttonStyle(.plain)

                        // Category Badge
                        HStack(spacing: 5) {
                            Image(systemName: item.category.systemImageName)
                                .foregroundColor(.secondary)
                                .font(.system(size: 11, weight: .semibold))

                            Text(item.isImage ? "Images (\(imageHistory.count))" : item.category.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(5)

                        // Stats
                        if item.isImage {
                            Text(formatImageStats(item))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(item.rawContent.count) chars • \(item.rawContent.components(separatedBy: .newlines).count) lines")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Minimal Action Options (Visible only on Mouse Hover!)
                        HStack(spacing: 6) {
                            // Star / Pin
                            Button(action: {
                                watcher.togglePin(item: item)
                            }) {
                                Image(systemName: item.isPinned ? "star.fill" : "star")
                                    .font(.system(size: 12))
                                    .foregroundColor(item.isPinned ? .yellow : .secondary)
                                    .padding(5)
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
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(5)
                            }
                            .buttonStyle(.plain)
                        }
                        .opacity(viewModel.isHovering ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.15), value: viewModel.isHovering)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.02))

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // FULL CONTENT BODY
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
                                    }
                                    if let count = item.imageData?.count {
                                        Text("•")
                                            .font(.system(size: 8))
                                            .foregroundColor(.secondary)
                                        Text("\(count / 1024) KB")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(6)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(20)
                            .background(Color.black.opacity(0.18))
                        }
                    } else {
                        // Text Viewer (Vertical scroll only, natural multiline text wrapping)
                        ScrollView(.vertical, showsIndicators: true) {
                            Text(item.rawContent)
                                .font(.system(size: 13, design: fontDesignForCategory(item.category)))
                                .foregroundColor(.white.opacity(0.95))
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    Divider()
                        .background(Color.white.opacity(0.08))

                    // Subtle Minimal Footer
                    HStack {
                        Text(formattedFullDate(item.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.8))

                        Spacer()

                        HStack(spacing: 10) {
                            KeyboardBadge(key: "↵", label: "Paste")
                            KeyboardBadge(key: "⌘C", label: "Copy")
                            KeyboardBadge(key: "Tab", label: "History")
                            KeyboardBadge(key: "esc", label: "Close")
                        }
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

    private func fontDesignForCategory(_ category: ClipCategory) -> Font.Design {
        switch category {
        case .json, .curl, .jwt, .sort:
            return .monospaced
        default:
            return .default
        }
    }

    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
        }
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
