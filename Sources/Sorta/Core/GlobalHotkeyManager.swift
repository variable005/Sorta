import Foundation
import AppKit

@MainActor
public final class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?

    public init() {}

    public func registerHotkey(onTogglePanel: @escaping () -> Void) {
        // Global monitor (fires when Sorta is NOT the active app)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            // Option + Space (keyCode 49) -> Toggle HUD Panel
            if modifiers == .option && event.keyCode == 49 {
                Task { @MainActor in
                    onTogglePanel()
                }
            }
        }

        // Local monitor (fires when Sorta HUD is active/key)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            if modifiers == .option && event.keyCode == 49 {
                Task { @MainActor in
                    onTogglePanel()
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
