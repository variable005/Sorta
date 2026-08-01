import SwiftUI

public struct HistoryListView: View {
    public let history: [ClipItem]
    public let searchQuery: String
    public let onSelect: (ClipItem) -> Void

    public init(history: [ClipItem], searchQuery: String, onSelect: @escaping (ClipItem) -> Void) {
        self.history = history
        self.searchQuery = searchQuery
        self.onSelect = onSelect
    }

    private var filteredHistory: [ClipItem] {
        if searchQuery.isEmpty {
            return history
        } else {
            return history.filter { $0.rawContent.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PAST CLIPBOARD ITEMS")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            if filteredHistory.isEmpty {
                Text("No items found")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(12)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredHistory) { item in
                            HistoryRowItemView(item: item) {
                                onSelect(item)
                            }
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
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
