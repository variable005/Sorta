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
        VStack(spacing: 0) {
            // Header Search Bar & Controls
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))

                TextField("Search history or type to filter...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))

                Spacer()

                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 4) {
                    Text("esc")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.08))
                        .cornerRadius(4)
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(Color.primary.opacity(0.03))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Current Clipboard Preview
                    if let item = watcher.currentItem {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label(watcher.currentCategory.rawValue, systemImage: watcher.currentCategory.systemImageName)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.blue)

                                Spacer()

                                Text("CURRENT CLIPBOARD")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }

                            Text(item.rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.primary)
                                .lineLimit(3)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.primary.opacity(0.04))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                        }
                    }

                    // Smart Actions (Direct 1..9 Execution)
                    if !watcher.currentOptions.isEmpty && viewModel.searchQuery.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("SMART ACTIONS")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text("PRESS 1–\(watcher.currentOptions.count) TO PASTE")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.blue)
                            }

                            VStack(spacing: 4) {
                                ForEach(watcher.currentOptions) { option in
                                    SmartActionRowView(option: option) {
                                        watcher.applyTransformAndPaste(option: option)
                                        PanelManager.shared.hidePanel()
                                    }
                                }
                            }
                        }
                    }

                    Divider()

                    // Clipboard History
                    HistoryListView(
                        viewModel: viewModel,
                        watcher: watcher
                    ) { selectedItem in
                        watcher.pasteRawItem(selectedItem)
                        PanelManager.shared.hidePanel()
                    }
                }
                .padding(14)
            }
        }
        .frame(width: 580, height: 440)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            KeyEventHandlerView { event in
                return viewModel.handleKeyDown(event: event)
            }
        )
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
