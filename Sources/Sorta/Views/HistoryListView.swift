import SwiftUI

public struct HistoryListView: View {
    @ObservedObject var watcher: PasteboardWatcher
    public let onSelect: (ClipItem) -> Void

    public init(watcher: PasteboardWatcher, onSelect: @escaping (ClipItem) -> Void) {
        self.watcher = watcher
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Bar & View Mode Toggle
            HStack {
                Text("PAST CLIPBOARD ITEMS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    watcher.isGroupedByCategory.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: watcher.isGroupedByCategory ? "folder.fill" : "clock.fill")
                            .font(.system(size: 9))
                        Text(watcher.isGroupedByCategory ? "By Category" : "Recent")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)

                if !watcher.history.isEmpty {
                    Button(action: {
                        watcher.clearHistory()
                    }) {
                        Text("Clear All")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 4)

            // Category Filter Pills Bar
            if !watcher.history.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        CategoryPillView(
                            title: "All (\(watcher.history.count))",
                            iconName: "square.grid.2x2",
                            isSelected: watcher.selectedCategory == nil
                        ) {
                            watcher.selectedCategory = nil
                        }

                        ForEach(watcher.categoriesInHistory) { cat in
                            let count = watcher.history.filter { $0.category == cat }.count
                            CategoryPillView(
                                title: "\(cat.rawValue) (\(count))",
                                iconName: cat.systemImageName,
                                isSelected: watcher.selectedCategory == cat
                            ) {
                                watcher.selectedCategory = (watcher.selectedCategory == cat) ? nil : cat
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // Main Content Area
            if watcher.filteredHistory.isEmpty {
                Text(watcher.history.isEmpty ? "No clipboard history yet" : "No items matching filter")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            } else {
                ScrollView {
                    if watcher.isGroupedByCategory {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(groupedCategories, id: \.self) { cat in
                                let items = itemsForCategory(cat)
                                if !items.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.systemImageName)
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.blue)
                                            Text(cat.rawValue.uppercased())
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.secondary)
                                            Text("(\(items.count))")
                                                .font(.system(size: 9))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.top, 4)

                                        ForEach(items) { item in
                                            HistoryRowItemView(item: item) {
                                                onSelect(item)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        LazyVStack(spacing: 4) {
                            ForEach(watcher.filteredHistory) { item in
                                HistoryRowItemView(item: item) {
                                    onSelect(item)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
    }

    private var groupedCategories: [ClipCategory] {
        if let selected = watcher.selectedCategory {
            return [selected]
        }
        return watcher.categoriesInHistory
    }

    private func itemsForCategory(_ category: ClipCategory) -> [ClipItem] {
        return watcher.filteredHistory.filter { $0.category == category }
    }
}

struct CategoryPillView: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 9))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .monospaced))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue : Color.primary.opacity(0.06))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct HistoryRowItemView: View {
    let item: ClipItem
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: item.category.systemImageName)
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.system(size: 12, design: .monospaced))
                        .lineLimit(1)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text(item.category.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.blue)

                        Text(item.category.domain.rawValue)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)

                        Text(formattedTime(item.createdAt))
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.03))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

