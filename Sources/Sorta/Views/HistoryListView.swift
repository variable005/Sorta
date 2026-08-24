import SwiftUI

public struct HistoryListView: View {
    @ObservedObject var viewModel: HUDViewModel
    @ObservedObject var watcher: PasteboardWatcher
    public let onSelect: (ClipItem) -> Void

    public init(viewModel: HUDViewModel, watcher: PasteboardWatcher, onSelect: @escaping (ClipItem) -> Void) {
        self.viewModel = viewModel
        self.watcher = watcher
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Bar
            HStack {
                Text("CLIPBOARD HISTORY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)

                Spacer()

                if !watcher.history.isEmpty {
                    Button(action: {
                        watcher.clearHistory(preservePinned: true)
                    }) {
                        Text("Clear Unpinned")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)

            // Category Filter Pills
            if !watcher.history.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        // Pinned Filter Pill
                        CategoryPillView(
                            title: "Pinned (\(watcher.pinnedItems.count))",
                            iconName: "star.fill",
                            isSelected: viewModel.isFilterPinnedOnly,
                            activeColor: .yellow
                        ) {
                            viewModel.isFilterPinnedOnly.toggle()
                        }

                        // All Pill
                        CategoryPillView(
                            title: "All (\(watcher.history.count))",
                            iconName: "tray.full",
                            isSelected: viewModel.selectedCategory == nil && !viewModel.isFilterPinnedOnly
                        ) {
                            viewModel.isFilterPinnedOnly = false
                            viewModel.selectedCategory = nil
                        }

                        // Categories in History
                        ForEach(viewModel.categoriesInHistory) { cat in
                            let count = watcher.history.filter { $0.category == cat }.count
                            CategoryPillView(
                                title: "\(cat.rawValue) (\(count))",
                                iconName: cat.systemImageName,
                                isSelected: viewModel.selectedCategory == cat && !viewModel.isFilterPinnedOnly
                            ) {
                                viewModel.isFilterPinnedOnly = false
                                viewModel.selectedCategory = (viewModel.selectedCategory == cat) ? nil : cat
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // Main List
            if viewModel.filteredHistory.isEmpty {
                Text(watcher.history.isEmpty ? "No clipboard history yet" : "No items matching filter")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(Array(viewModel.filteredHistory.enumerated()), id: \.element.id) { idx, item in
                                HistoryRowItemView(
                                    item: item,
                                    isSelected: idx == viewModel.selectedIndex,
                                    onSelect: { onSelect(item) },
                                    onTogglePin: { watcher.togglePin(item: item) },
                                    onDelete: { watcher.delete(item: item) }
                                )
                                .id(idx)
                            }
                        }
                    }
                    .frame(maxHeight: 190)
                    .onChange(of: viewModel.selectedIndex) { _, newIdx in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            proxy.scrollTo(newIdx, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

struct CategoryPillView: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    var activeColor: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.system(size: 9))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .monospaced))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? activeColor : Color.primary.opacity(0.06))
            .foregroundColor(isSelected ? (activeColor == .yellow ? .black : .white) : .primary)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct HistoryRowItemView: View {
    let item: ClipItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onSelect) {
                HStack(spacing: 10) {
                    Image(systemName: item.category.systemImageName)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .frame(width: 18)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.system(size: 12, design: .monospaced))
                            .lineLimit(1)
                            .foregroundColor(.primary)

                        HStack(spacing: 6) {
                            Text(item.category.rawValue)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.blue)

                            Text("•")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)

                            Text(formattedTime(item.createdAt))
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    if isSelected {
                        Text("↵ Paste")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.12))
                            .cornerRadius(4)
                    }
                }
            }
            .buttonStyle(.plain)

            // Pin Button
            Button(action: onTogglePin) {
                Image(systemName: item.isPinned ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(item.isPinned ? .yellow : .secondary.opacity(0.4))
                    .padding(4)
            }
            .buttonStyle(.plain)

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            isSelected ? Color.blue.opacity(0.12) : Color.primary.opacity(0.02)
        )
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
