import SwiftUI
import AppKit

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
                            title: "All",
                            iconName: "tray.full",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                viewModel.selectedCategory = nil
                            }
                        }

                        ForEach(viewModel.categoriesInHistory) { cat in
                            CategoryPillView(
                                title: cat.rawValue,
                                iconName: cat.systemImageName,
                                isSelected: viewModel.selectedCategory == cat
                            ) {
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                    viewModel.selectedCategory = (viewModel.selectedCategory == cat) ? nil : cat
                                }
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
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                                ForEach(Array(viewModel.filteredHistory.enumerated()), id: \.element.id) { idx, item in
                                    ImageGridCell(
                                        item: item,
                                        isSelected: idx == viewModel.selectedIndex,
                                        onSelect: {
                                            withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) {
                                                viewModel.selectedIndex = idx
                                            }
                                            onSelect(item)
                                        },
                                        onDoubleClick: {
                                            onDoubleClick(item)
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
                                            withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) {
                                                viewModel.selectedIndex = idx
                                            }
                                            onSelect(item)
                                        },
                                        onDoubleClick: {
                                            onDoubleClick(item)
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
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) {
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 9))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(isSelected ? Color.white.opacity(0.20) : Color.white.opacity(0.06))
            .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
            .cornerRadius(6)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct ImageGridCell: View {
    let item: ClipItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .center) {
                if let data = item.imageData, let img = NSImage(data: data) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .padding(4)
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                        .frame(height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.04))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
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

struct CompactHistoryRow: View {
    let item: ClipItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                if item.isImage, let data = item.imageData, let img = NSImage(data: data) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
                        )
                } else {
                    Image(systemName: item.category.systemImageName)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .primary : .secondary)
                        .frame(width: 16)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.isImage ? "Image" : item.rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
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
            .animation(.spring(response: 0.18, dampingFraction: 0.85), value: isSelected)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onDoubleClick()
        })
        .onDrag {
            if item.isImage {
                return DragItemProviderHelper.createImageItemProvider(item: item)
            } else {
                return NSItemProvider(object: item.rawContent as NSString)
            }
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
