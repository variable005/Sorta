import Foundation
import Combine
import AppKit

@MainActor
public final class QueueManager: ObservableObject {
    public static let shared = QueueManager()

    @Published public private(set) var isQueueModeEnabled: Bool = false
    @Published public private(set) var queueStack: [String] = []

    public init() {}

    public func toggleQueueMode() {
        isQueueModeEnabled.toggle()
        if !isQueueModeEnabled {
            queueStack.removeAll()
        }
    }

    public func pushItem(_ content: String) {
        guard isQueueModeEnabled else { return }
        if queueStack.last != content {
            queueStack.append(content)
        }
    }

    public func popAndPaste() -> String? {
        guard !queueStack.isEmpty else { return nil }
        let nextItem = queueStack.removeFirst()

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(nextItem, forType: .string)

        simulateCmdV()
        return nextItem
    }

    public func clearQueue() {
        queueStack.removeAll()
    }

    private func simulateCmdV() {
        let src = CGEventSource(stateID: .combinedSessionState)
        let vKeyCode: CGKeyCode = 0x09

        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: true)
        keyDown?.flags = .maskCommand

        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
