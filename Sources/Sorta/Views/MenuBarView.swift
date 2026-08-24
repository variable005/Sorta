import SwiftUI
import AppKit

@MainActor
public final class MenuBarManager: ObservableObject {
    public static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private weak var watcher: PasteboardWatcher?

    public init() {}

    public func setup(watcher: PasteboardWatcher) {
        self.watcher = watcher

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "scissors", accessibilityDescription: "Sorta")
        }

        buildMenu()
    }

    public func buildMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: "Toggle SORTA Panel (Tap Control 3x)",
            action: #selector(togglePanel),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

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

    @objc private func togglePanel() {
        PanelManager.shared.togglePanel()
    }

    @objc private func clearHistory() {
        watcher?.clearHistory()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
