import SwiftUI

public struct SortaHUDView: View {
    @ObservedObject var watcher: PasteboardWatcher
    @ObservedObject var queueManager = QueueManager.shared

    public init(watcher: PasteboardWatcher) {
        self.watcher = watcher
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Search Bar & Brand Title
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))

                TextField("Search history or filter actions...", text: $watcher.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))

                Spacer()

                if queueManager.isQueueModeEnabled {
                    Text("QUEUE STACK (\(queueManager.queueStack.count))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }

                Text("SORTA")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            .padding(14)
            .background(Color.primary.opacity(0.03))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Queue Banner if Queue items exist
                    if queueManager.isQueueModeEnabled && !queueManager.queueStack.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("SEQUENTIAL QUEUE STACK")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.orange)

                                Spacer()

                                Button("Clear Queue") {
                                    queueManager.clearQueue()
                                }
                                .buttonStyle(.plain)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            }

                            ForEach(Array(queueManager.queueStack.enumerated()), id: \.offset) { idx, item in
                                HStack {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .frame(width: 16)

                                    Text(item)
                                        .font(.system(size: 11, design: .monospaced))
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                }
                                .padding(6)
                                .background(Color.orange.opacity(0.06))
                                .cornerRadius(4)
                            }
                        }
                        Divider()
                    }

                    // Current Item Preview Section
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

                    // Smart Actions Section
                    if !watcher.currentOptions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SMART TRANSFORMATIONS (PRESS NUMBER KEY)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)

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

                    // History Section
                    HistoryListView(
                        history: watcher.history,
                        searchQuery: watcher.searchQuery
                    ) { selectedItem in
                        let pasteboardOption = TransformOption(
                            title: "Paste Raw",
                            detail: selectedItem.rawContent,
                            transformedContent: selectedItem.rawContent
                        )
                        watcher.applyTransformAndPaste(option: pasteboardOption)
                        PanelManager.shared.hidePanel()
                    }
                }
                .padding(14)
            }
        }
        .frame(width: 560, height: 420)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
