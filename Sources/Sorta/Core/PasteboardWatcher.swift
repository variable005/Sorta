import Foundation
import AppKit
import Combine

@MainActor
public final class PasteboardWatcher: ObservableObject {
    @Published public private(set) var currentItem: ClipItem?
    @Published public private(set) var currentCategory: ClipCategory = .text
    @Published public private(set) var currentOptions: [TransformOption] = []
    @Published public private(set) var history: [ClipItem] = []
    @Published public var searchQuery: String = ""

    private var lastChangeCount: Int = -1
    private var timer: Timer?

    public init() {}

    public func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        checkPasteboard()

        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    public func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let newString = pasteboard.string(forType: .string), !newString.isEmpty else {
            return
        }

        let (category, options) = TransformerRegistry.shared.inspect(content: newString)

        let newItem = ClipItem(
            rawContent: newString,
            category: category,
            createdAt: Date()
        )

        self.currentItem = newItem
        self.currentCategory = category
        self.currentOptions = options

        if history.first?.rawContent != newString {
            history.insert(newItem, at: 0)
            if history.count > 50 {
                history.removeLast()
            }
        }
    }

    public func applyTransformAndPaste(option: TransformOption) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(option.transformedContent, forType: .string)

        lastChangeCount = pasteboard.changeCount

        if var item = currentItem {
            item.lastTransformedContent = option.transformedContent
            self.currentItem = item
        }

        simulateCmdV()
    }

    public func copyToClipboard(content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        lastChangeCount = pasteboard.changeCount
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
