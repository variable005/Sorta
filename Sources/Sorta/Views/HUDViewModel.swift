import Foundation
import SwiftUI
import Combine

@MainActor
public final class HUDViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: ClipCategory? = nil
    @Published public var isFilterPinnedOnly: Bool = false
    @Published public var selectedIndex: Int = 0

    private weak var watcher: PasteboardWatcher?
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

    public func handleKeyDown(event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // 1. Escape -> Hide Panel
        if event.keyCode == 53 { // Escape
            PanelManager.shared.hidePanel()
            return true
        }

        // 2. Number Keys 1..9 (when search bar is empty and no modifiers)
        if modifiers.isEmpty, let chars = event.charactersIgnoringModifiers, let num = Int(chars), num >= 1 && num <= 9 {
            if searchQuery.isEmpty {
                if let options = watcher?.currentOptions, num - 1 < options.count {
                    let option = options[num - 1]
                    watcher?.applyTransformAndPaste(option: option)
                    PanelManager.shared.hidePanel()
                    return true
                }
            }
        }

        // 3. Up / Down Arrows for History Navigation
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

        // 4. Return / Enter -> Paste Selected
        if event.keyCode == 36 { // Enter
            let items = filteredHistory
            if selectedIndex >= 0 && selectedIndex < items.count {
                let item = items[selectedIndex]
                watcher?.pasteRawItem(item)
                PanelManager.shared.hidePanel()
                return true
            } else if let current = watcher?.currentItem {
                watcher?.pasteRawItem(current)
                PanelManager.shared.hidePanel()
                return true
            }
        }

        // 5. Cmd + P or Cmd + S -> Toggle Pin on selected item
        if (modifiers == .command && (event.keyCode == 35 || event.keyCode == 1)) { // P or S
            let items = filteredHistory
            if selectedIndex >= 0 && selectedIndex < items.count {
                watcher?.togglePin(item: items[selectedIndex])
                return true
            }
        }

        // 6. Cmd + Backspace -> Delete selected item
        if modifiers == .command && event.keyCode == 51 { // Delete
            let items = filteredHistory
            if selectedIndex >= 0 && selectedIndex < items.count {
                watcher?.delete(item: items[selectedIndex])
                if selectedIndex >= items.count - 1 && selectedIndex > 0 {
                    selectedIndex -= 1
                }
                return true
            }
        }

        return false
    }
}
