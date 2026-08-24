import Foundation
import SwiftUI
import Combine

@MainActor
public final class HUDViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: ClipCategory? = nil
    @Published public var isFilterPinnedOnly: Bool = false
    @Published public var selectedIndex: Int = 0

    public weak var watcher: PasteboardWatcher?
    private var cancellables = Set<AnyCancellable>()

    public init(watcher: PasteboardWatcher) {
        self.watcher = watcher

        // Reset selection index when search query or category filter changes
        Publishers.Merge3(
            $searchQuery.map { _ in () },
            $selectedCategory.map { _ in () },
            $isFilterPinnedOnly.map { _ in () }
        )
        .sink { [weak self] _ in
            self?.selectedIndex = 0
        }
        .store(in: &cancellables)
    }

    public var filteredHistory: [ClipItem] {
        guard let history = watcher?.history else { return [] }
        return history.filter { item in
            let matchesPinned = !isFilterPinnedOnly || item.isPinned
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let matchesSearch = searchQuery.isEmpty || item.rawContent.localizedCaseInsensitiveContains(searchQuery)
            return matchesPinned && matchesCategory && matchesSearch
        }
    }

    public var categoriesInHistory: [ClipCategory] {
        guard let history = watcher?.history else { return [] }
        let present = Set(history.map { $0.category })
        return ClipCategory.allCases.filter { present.contains($0) }
    }

    public var currentSelectedItem: ClipItem? {
        let items = filteredHistory
        if selectedIndex >= 0 && selectedIndex < items.count {
            return items[selectedIndex]
        }
        return watcher?.currentItem ?? items.first
    }

    public func handleKeyDown(event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // 1. Escape -> Hide Panel
        if event.keyCode == 53 { // Escape
            PanelManager.shared.hidePanel()
            return true
        }

        // 2. Up / Down Arrows for History Navigation
        if event.keyCode == 126 { // Up Arrow
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            return true
        } else if event.keyCode == 125 { // Down Arrow
            let count = filteredHistory.count
            if selectedIndex < count - 1 {
                selectedIndex += 1
            }
            return true
        }

        // 3. Return / Enter -> Paste Selected
        if event.keyCode == 36 { // Enter
            if let item = currentSelectedItem {
                watcher?.pasteRawItem(item)
                PanelManager.shared.hidePanel()
                return true
            }
        }

        // 4. Cmd + C -> Copy Selected to clipboard
        if modifiers == .command && event.keyCode == 8 { // C
            if let item = currentSelectedItem {
                watcher?.copyToClipboard(content: item.rawContent)
                PanelManager.shared.hidePanel()
                return true
            }
        }

        // 5. Cmd + P or Cmd + S -> Toggle Pin on selected item
        if modifiers == .command && (event.keyCode == 35 || event.keyCode == 1) { // P or S
            if let item = currentSelectedItem {
                watcher?.togglePin(item: item)
                return true
            }
        }

        // 6. Cmd + Backspace -> Delete selected item
        if modifiers == .command && event.keyCode == 51 { // Delete
            if let item = currentSelectedItem {
                watcher?.delete(item: item)
                let items = filteredHistory
                if selectedIndex >= items.count && selectedIndex > 0 {
                    selectedIndex -= 1
                }
                return true
            }
        }

        return false
    }
}
