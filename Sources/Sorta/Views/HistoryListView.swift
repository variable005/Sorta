import SwiftUI

public struct HistoryListView: View {
    @ObservedObject var viewModel: HUDViewModel
    @ObservedObject var watcher: PasteboardWatcher
    public let onSelect: (ClipItem) -> Void
    public let onDoubleClick: (ClipItem) -> Void

    public init(
        viewModel: HUDViewModel,
        watcher: PasteboardWatcher,
        onSelect: @escaping (ClipItem) -> Void,
        onDoubleClick: @escaping (ClipItem) -> Void
    ) {
        self.viewModel = viewModel
        self.watcher = watcher
        self.onSelect = onSelect
        self.onDoubleClick = onDoubleClick
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Category Filter Pills
            if !watcher.history.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        CategoryPillView(
                            title: "All (\(watcher.history.count))",
                            iconName: "tray.full",
                            isSelected: viewModel.selectedCategory == nil && !viewModel.isFilterPinnedOnly
                        ) {
                            viewModel.isFilterPinnedOnly = false
                            viewModel.selectedCategory = nil
                        }

                        CategoryPillView(
                            title: "Pinned (\(watcher.pinnedItems.count))",
                            iconName: "star.fill",
                            isSelected: viewModel.isFilterPinnedOnly,
                            activeColor: .yellow
                        ) {
                            viewModel.isFilterPinnedOnly.toggle()
                        }

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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }
            }

            // Main List or Image Grid
            if viewModel.filteredHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text(watcher.history.isEmpty ? "No clipboard history yet" : "No matching items")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 30)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        if viewModel.selectedCategory == .image {
                            // 2-Column Responsive Image Grid
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                                ForEach(Array(viewModel.filteredHistory.enumerated()), id: \.element.id) { idx, item in
                                    ImageGridCell(
                                        item: item,
                                        isSelected: idx == viewModel.selectedIndex,
                                        onSelect: {
                                            viewModel.selectedIndex = idx
                                            onSelect(item)
                                        },
                                        onDoubleClick: {
                                            onDoubleClick(item)
                                        },
                                        onTogglePin: {
                                            watcher.togglePin(item: item)
                                        }
                                    )
                                    .id(idx)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        } else {
                            // Standard Compact List
                            LazyVStack(spacing: 3) {
                                ForEach(Array(viewModel.filteredHistory.enumerated()), id: \.element.id) { idx, item in
                                    CompactHistoryRow(
                                        item: item,
                                        isSelected: idx == viewModel.selectedIndex,
                                        onSelect: {
                                            viewModel.selectedIndex = idx
                                            onSelect(item)
                                        },
                                        onDoubleClick: {
                                            onDoubleClick(item)
                                        },
                                        onTogglePin: {
                                            watcher.togglePin(item: item)
                                        }
                                    )
                                    .id(idx)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                    }
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
    var activeColor: Color = Color.white.opacity(0.22)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 8))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(isSelected ? activeColor : Color.white.opacity(0.06))
            .foregroundColor(isSelected ? (activeColor == .yellow ? .black : .white) : .primary.opacity(0.8))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

struct ImageGridCell: View {
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
                        .frame(height: 75)
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
                        .frame(height: 75)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                }

                // Dark gradient overlay at bottom
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 26)

                // Info overlay
                HStack(spacing: 3) {
                    if let dims = item.imageDimensions {
                        Text(dims)
                            .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }

                    Spacer()

                    if item.isPinned {
                        Image(systemName: "star.fill")
                            .font(.system(size: 7.5))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 3)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onDoubleClick()
        })
    }
}

struct CompactHistoryRow: View {
    let item: ClipItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void
    let onTogglePin: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                if item.isImage, let data = item.imageData, let img = NSImage(data: data) {
                    Color.clear
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(nsImage: img)
                                .resizable()
                                .scaledToFill()
                        )
                        .cornerRadius(3)
                        .clipped()
                } else {
                    Image(systemName: item.category.systemImageName)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .primary : .secondary)
                        .frame(width: 16)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .foregroundColor(isSelected ? .white : .primary)

                    HStack(spacing: 4) {
                        Text(item.category.rawValue)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)

                        Text("•")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)

                        Text(formattedTime(item.createdAt))
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if item.isPinned {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color.white.opacity(0.12) : Color.clear
            )
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.white.opacity(0.20) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onDoubleClick()
        })
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
