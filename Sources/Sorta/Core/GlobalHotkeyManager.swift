import Foundation
import AppKit

@MainActor
public final class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?

    public init() {}

    public func registerHotkey(onTriggerPanel: @escaping () -> Void) {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags

            // Option + Space (keyCode 49) -> Toggle Panel
            if modifiers.contains(.option) && !modifiers.contains(.shift) && event.keyCode == 49 {
                Task { @MainActor in
                    onTriggerPanel()
                }
            }

            // Option + Shift + C (keyCode 8) -> Toggle Queue Mode
            if modifiers.contains(.option) && modifiers.contains(.shift) && event.keyCode == 8 {
                Task { @MainActor in
                    QueueManager.shared.toggleQueueMode()
                }
            }

            // Option + Shift + V (keyCode 9) -> Pop and paste next queue item
            if modifiers.contains(.option) && modifiers.contains(.shift) && event.keyCode == 9 {
                Task { @MainActor in
                    _ = QueueManager.shared.popAndPaste()
                }
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags

            if modifiers.contains(.option) && !modifiers.contains(.shift) && event.keyCode == 49 {
                Task { @MainActor in
                    onTriggerPanel()
                }
                return nil
            }

            if modifiers.contains(.option) && modifiers.contains(.shift) && event.keyCode == 8 {
                Task { @MainActor in
                    QueueManager.shared.toggleQueueMode()
                }
                return nil
            }

            if modifiers.contains(.option) && modifiers.contains(.shift) && event.keyCode == 9 {
                Task { @MainActor in
                    _ = QueueManager.shared.popAndPaste()
                }
                return nil
            }

            return event
        }
    }

    public func unregister() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
}
