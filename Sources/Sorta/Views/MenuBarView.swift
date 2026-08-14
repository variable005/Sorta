import SwiftUI
import AppKit

@MainActor
public final class MenuBarManager: ObservableObject {
    public static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private var watcher: PasteboardWatcher?

    public init() {}

    public func setup(watcher: PasteboardWatcher) {
        self.watcher = watcher

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "scissors", accessibilityDescription: "Sorta")
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        buildMenu()
    }

    public func buildMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: "Toggle SORTA Panel (Option+Space)",
            action: #selector(togglePanel),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Categorized History Submenu
        if let watcher = watcher, !watcher.history.isEmpty {
            let catMenuHeader = NSMenuItem(title: "Categorized History", action: nil, keyEquivalent: "")
            let catSubmenu = NSMenu()

            for cat in watcher.categoriesInHistory {
                let items = watcher.history.filter { $0.category == cat }
                if !items.isEmpty {
                    let catItem = NSMenuItem(title: "\(cat.rawValue) (\(items.count))", action: nil, keyEquivalent: "")
                    let catItemSubmenu = NSMenu()

                    for clip in items.prefix(10) {
                        let snippet = String(clip.rawContent.prefix(40)).replacingOccurrences(of: "\n", with: " ")
                        let subMenuItem = NSMenuItem(title: snippet, action: #selector(copyHistorySnippet(_:)), keyEquivalent: "")
                        subMenuItem.representedObject = clip.rawContent
                        subMenuItem.target = self
                        catItemSubmenu.addItem(subMenuItem)
                    }

                    catItem.submenu = catItemSubmenu
                    catSubmenu.addItem(catItem)
                }
            }

            catMenuHeader.submenu = catSubmenu
            menu.addItem(catMenuHeader)
            menu.addItem(NSMenuItem.separator())
        }

        let clearItem = NSMenuItem(
            title: "Clear History",
            action: #selector(clearHistory),
            keyEquivalent: ""
        )
        clearItem.target = self
        menu.addItem(clearItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit SORTA",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func copyHistorySnippet(_ sender: NSMenuItem) {
        if let content = sender.representedObject as? String {
            watcher?.copyToClipboard(content: content)
        }
    }

    @objc private func statusItemClicked() {
        PanelManager.shared.togglePanel()
    }

    @objc private func togglePanel() {
        PanelManager.shared.togglePanel()
    }

    @objc private func clearHistory() {
        watcher?.clearHistory()
        buildMenu()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

