import Foundation
import AppKit

@MainActor
public final class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()

    private var globalFlagsMonitor: Any?
    private var localFlagsMonitor: Any?
    private var globalKeyMonitor: Any?
    private var localKeyMonitor: Any?

    private var isControlDown: Bool = false
    private var tapCount: Int = 0
    private var lastTapTimestamp: TimeInterval = 0

    public init() {}

    public func registerHotkey(onTogglePanel: @escaping () -> Void) {
        // 1. Triple Control Tap Detector (Flags Changed)
        globalFlagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsEvent(event: event, onTogglePanel: onTogglePanel)
        }

        localFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsEvent(event: event, onTogglePanel: onTogglePanel)
            return event
        }

        // 2. Option + Space Fallback (Key Down)
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event: event, onTogglePanel: onTogglePanel)
        }

        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event: event, onTogglePanel: onTogglePanel) == true {
                return nil
            }
            return event
        }
    }

    private func handleFlagsEvent(event: NSEvent, onTogglePanel: @escaping () -> Void) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isCtrlNow = modifiers.contains(.control)

        // Only count if ONLY Control key is being pressed (no Cmd, Option, Shift)
        let onlyControl = modifiers == [.control]

        if isCtrlNow && !isControlDown && onlyControl {
            let now = ProcessInfo.processInfo.systemUptime
            if (now - lastTapTimestamp) < 0.50 {
                tapCount += 1
            } else {
                tapCount = 1
            }
            lastTapTimestamp = now

            if tapCount >= 3 {
                tapCount = 0
                Task { @MainActor in
                    onTogglePanel()
                }
            }
        } else if !isCtrlNow && isControlDown {
            // Control released - keep tap count intact for next press
        } else if modifiers.contains(.command) || modifiers.contains(.option) || modifiers.contains(.shift) {
            // Reset if interrupted by other keys/modifiers
            tapCount = 0
        }

        isControlDown = isCtrlNow
    }

    private func handleKeyEvent(event: NSEvent, onTogglePanel: @escaping () -> Void) -> Bool {
        // Any regular keypress resets the multi-tap modifier count
        tapCount = 0

        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Option + Space (keyCode 49) or Control + Space
        if (modifiers == .option || modifiers == .control) && event.keyCode == 49 {
            Task { @MainActor in
                onTogglePanel()
            }
            return true
        }

        return false
    }

    public func unregister() {
        if let monitor = globalFlagsMonitor {
            NSEvent.removeMonitor(monitor)
            globalFlagsMonitor = nil
        }
        if let monitor = localFlagsMonitor {
            NSEvent.removeMonitor(monitor)
            localFlagsMonitor = nil
        }
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
    }
}
