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
            // LEFT COLUMN: Search & History List (Width 290)
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))

                    TextField("Search clipboard...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))

                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.04))

                Divider()
                    .background(Color.white.opacity(0.1))

                // History List with Category Filter Pills
                HistoryListView(
                    viewModel: viewModel,
                    watcher: watcher,
                    onSelect: { selectedItem in
                        // Selection already updates automatically
                    },
                    onDoubleClick: { selectedItem in
                        watcher.pasteRawItem(selectedItem)
                        PanelManager.shared.hidePanel()
                    }
                )

                Spacer(minLength: 0)

                Divider()
                    .background(Color.white.opacity(0.1))

                // Left Footer
                HStack {
                    Text("\(viewModel.filteredHistory.count) items")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)

                    Spacer()

                    if !watcher.history.isEmpty {
                        Button("Clear Unpinned") {
                            watcher.clearHistory(preservePinned: true)
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.02))
            }
            .frame(width: 290)

            Divider()
                .background(Color.white.opacity(0.15))

            // RIGHT COLUMN: Full Content Viewer (Flex width)
            VStack(spacing: 0) {
                if let item = viewModel.currentSelectedItem {
                    // Header Bar
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: item.category.systemImageName)
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .bold))

                            Text(item.category.rawValue)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(6)

                        Text("• \(item.rawContent.count) chars, \(item.rawContent.components(separatedBy: .newlines).count) lines")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)

                        Spacer()

                        // Star / Pin Button
                        Button(action: {
                            watcher.togglePin(item: item)
                        }) {
                            Image(systemName: item.isPinned ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(item.isPinned ? .yellow : .secondary)
                                .padding(5)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(5)
                        }
                        .buttonStyle(.plain)

                        // Copy Button
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

                        // Paste Button
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.03))

                    Divider()
                        .background(Color.white.opacity(0.1))

                    // FULL CONTENT BODY (Scrollable, complete content display)
                    ScrollView([.vertical, .horizontal]) {
                        Text(item.rawContent)
                            .font(.system(size: 12.5, design: fontDesignForCategory(item.category)))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                            .padding(14)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .background(Color.black.opacity(0.35))

                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Footer Keyboard Helper
                    HStack {
                        Text(formattedFullDate(item.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Spacer()

                        HStack(spacing: 12) {
                            KeyboardBadge(key: "↵", label: "Paste")
                            KeyboardBadge(key: "⌘C", label: "Copy")
                            KeyboardBadge(key: "⌘P", label: "Pin")
                            KeyboardBadge(key: "esc", label: "Close")
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.02))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("Select an item to view full content")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 740, height: 480)
        .background(
            ZStack {
                Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.96)
                VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
                .background(Color.white.opacity(0.12))
                .cornerRadius(3)
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 10))
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
