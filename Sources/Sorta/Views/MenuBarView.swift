import SwiftUI
import AppKit

@MainActor
public final class MenuBarManager: ObservableObject {
    public static let shared = MenuBarManager()

    private var statusItem: NSStatusItem?
    private weak var watcher: PasteboardWatcher?
    private var contextMenu: NSMenu?

    public init() {}

    public func setup(watcher: PasteboardWatcher) {
        self.watcher = watcher

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            let image = NSImage(systemSymbolName: "square.on.square", accessibilityDescription: "Sorta")
            image?.isTemplate = true
            button.image = image
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        buildContextMenu()
    }

    private func buildContextMenu() {
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

        self.contextMenu = menu
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            // Right-click opens options menu
            if let menu = contextMenu {
                statusItem?.menu = menu
                statusItem?.button?.performClick(nil)
                statusItem?.menu = nil // Clear so left click continues to trigger action
            }
        } else {
            // Left-click directly toggles the HUD panel!
            PanelManager.shared.togglePanel()
        }
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
