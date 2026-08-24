import SwiftUI
import AppKit

public struct SortaHUDView: View {
    @ObservedObject var watcher: PasteboardWatcher
    @StateObject private var viewModel: HUDViewModel

    public init(watcher: PasteboardWatcher) {
        self.watcher = watcher
        self._viewModel = StateObject(wrappedValue: HUDViewModel(watcher: watcher))
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
                            .foregroundColor(viewModel.isSidebarVisible ? .blue : .secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(viewModel.isSidebarVisible ? 0.12 : (viewModel.isHovering ? 0.08 : 0.0)))
                            .cornerRadius(5)
                        }
                        .buttonStyle(.plain)

                        // Category Badge
                        HStack(spacing: 5) {
                            Image(systemName: item.category.systemImageName)
                                .foregroundColor(.blue)
                                .font(.system(size: 11, weight: .semibold))

                            Text(item.category.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(5)

                        // Stats
                        Text("\(item.rawContent.count) chars • \(item.rawContent.components(separatedBy: .newlines).count) lines")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.secondary)

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
                                watcher.copyToClipboard(content: item.rawContent)
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
                                .foregroundColor(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Color.blue)
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

                    // FULL CONTENT BODY (Vertical scroll only, natural multiline text wrapping)
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
                Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.96)
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
