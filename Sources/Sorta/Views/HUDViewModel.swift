import Foundation
import SwiftUI
import Combine

@MainActor
public final class HUDViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: ClipCategory? = nil
    @Published public var isFilterPinnedOnly: Bool = false
    @Published public var selectedIndex: Int = 0
    @Published public var isSidebarVisible: Bool = false
    @Published public var isHovering: Bool = false
    @Published public var justCopied: Bool = false

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

    public func copyWithAnimation(item: ClipItem) {
        watcher?.copyItemToClipboard(item)
        withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
            justCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { [weak self] in
            PanelManager.shared.hidePanel()
            self?.justCopied = false
        }
    }

    public func handleKeyDown(event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // 1. Escape -> Hide Panel
        if event.keyCode == 53 { // Escape
            PanelManager.shared.hidePanel()
            return true
        }

        // 2. Tab or Cmd + H -> Toggle Sidebar with Spring
        if event.keyCode == 48 || (modifiers == .command && event.keyCode == 4) { // Tab or Cmd + H
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                isSidebarVisible.toggle()
            }
            return true
        }

        // 3. Up / Down Arrows for History Navigation
        if event.keyCode == 126 { // Up Arrow
            if !isSidebarVisible {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { isSidebarVisible = true }
            }
            if selectedIndex > 0 {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.88)) {
                    selectedIndex -= 1
                }
            }
            return true
        } else if event.keyCode == 125 { // Down Arrow
            if !isSidebarVisible {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { isSidebarVisible = true }
            }
            let count = filteredHistory.count
            if selectedIndex < count - 1 {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.88)) {
                    selectedIndex += 1
                }
            }
            return true
        }

        // 4. Return / Enter -> Paste Selected
        if event.keyCode == 36 { // Enter
            if let item = currentSelectedItem {
                watcher?.pasteRawItem(item)
                PanelManager.shared.hidePanel()
                return true
            }
        }

        // 5. Cmd + C -> Copy Selected with animated feedback
        if modifiers == .command && event.keyCode == 8 { // C
            if let item = currentSelectedItem {
                copyWithAnimation(item: item)
                return true
            }
        }

        // 6. Cmd + P or Cmd + S -> Toggle Pin on selected item
        if modifiers == .command && (event.keyCode == 35 || event.keyCode == 1) { // P or S
            if let item = currentSelectedItem {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.52)) {
                    watcher?.togglePin(item: item)
                }
                return true
            }
        }

        // 7. Cmd + Backspace -> Delete selected item
        if modifiers == .command && event.keyCode == 51 { // Delete
            if let item = currentSelectedItem {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                    watcher?.delete(item: item)
                    let items = filteredHistory
                    if selectedIndex >= items.count && selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                }
                return true
            }
        }

        return false
    }
}
