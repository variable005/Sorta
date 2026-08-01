import Foundation
import AppKit

@MainActor
public final class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?

    public init() {}

    public func registerHotkey(onTrigger: @escaping () -> Void) {
        // Monitor global key presses (Cmd + Shift + V or Option + Space)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            // Option + Space
            if event.modifierFlags.contains(.option) && event.keyCode == 49 {
                Task { @MainActor in
                    onTrigger()
                }
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.option) && event.keyCode == 49 {
                Task { @MainActor in
                    onTrigger()
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
