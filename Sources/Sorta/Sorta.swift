import SwiftUI
import AppKit

@main
struct SortaApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let watcher = PasteboardWatcher()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start pasteboard change observer
        watcher.startMonitoring()

        // Setup floating panel UI
        let hudView = SortaHUDView(watcher: watcher)
        PanelManager.shared.configure(with: hudView)

        // Setup menu bar icon
        MenuBarManager.shared.setup(watcher: watcher)

        // Register global shortcut listener
        GlobalHotkeyManager.shared.registerHotkey {
            PanelManager.shared.togglePanel()
        }

        print("SORTA loaded successfully. Press Option + Space to open HUD.")
    }

    func applicationWillTerminate(_ notification: Notification) {
        watcher.stopMonitoring()
        GlobalHotkeyManager.shared.unregister()
    }
}
