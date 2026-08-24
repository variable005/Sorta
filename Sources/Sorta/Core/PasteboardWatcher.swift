import Foundation
import AppKit
import Combine

@MainActor
public final class PasteboardWatcher: ObservableObject {
    @Published public private(set) var currentItem: ClipItem?
    @Published public private(set) var currentCategory: ClipCategory = .text
    @Published public private(set) var currentOptions: [TransformOption] = []
    @Published public private(set) var history: [ClipItem] = []

    private let storageKey = "Sorta_ClipboardHistory_v2"
    private var lastChangeCount: Int = -1
    private var timer: Timer?

    public var pinnedItems: [ClipItem] {
        history.filter { $0.isPinned }
    }

    public init() {
        loadState()
    }

    public func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        checkPasteboard()

        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
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

        // 1. Password manager exclusion
        if PrivacyGuard.shared.isFromIgnoredApplication() {
            return
        }

        guard let newString = pasteboard.string(forType: .string), !newString.isEmpty else {
            return
        }

        // 2. Sensitive Data Handling
        let isSensitive = PrivacyGuard.shared.isSensitiveContent(newString)
        let displayContent = isSensitive ? PrivacyGuard.shared.maskSensitiveContent(newString) : newString

        if isSensitive {
            PrivacyGuard.shared.scheduleAutoExpiry(for: newString, seconds: 30.0) { [weak self] in
                if self?.currentItem?.rawContent == displayContent {
                    self?.currentItem = nil
                }
            }
        }

        // 3. Inspect and classify
        let (category, options) = TransformerRegistry.shared.inspect(content: newString)

        let newItem = ClipItem(
            rawContent: displayContent,
            category: category,
            createdAt: Date()
        )

        self.currentItem = newItem
        self.currentCategory = category
        self.currentOptions = options

        // 4. Update History (Deduplicate consecutive identical items)
        if history.first?.rawContent != displayContent {
            history.insert(newItem, at: 0)
            if history.count > 50 {
                history.removeLast()
            }
            saveState()
        }
    }

    public func togglePin(item: ClipItem) {
        if let idx = history.firstIndex(where: { $0.id == item.id }) {
            history[idx].isPinned.toggle()
            saveState()
        }
    }

    public func delete(item: ClipItem) {
        if let idx = history.firstIndex(where: { $0.id == item.id }) {
            history.remove(at: idx)
            saveState()
        }
    }

    public func clearHistory(preservePinned: Bool = true) {
        if preservePinned {
            history = history.filter { $0.isPinned }
        } else {
            history.removeAll()
        }
        saveState()
    }

    public func applyTransformAndPaste(option: TransformOption) {
        copyToClipboard(content: option.transformedContent)

        if var item = currentItem {
            item.lastTransformedContent = option.transformedContent
            self.currentItem = item
        }

        simulateCmdV()
    }

    public func pasteRawItem(_ item: ClipItem) {
        copyToClipboard(content: item.rawContent)
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
        let vKeyCode: CGKeyCode = 0x09 // Virtual key for 'V'

        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: true)
        keyDown?.flags = .maskCommand

        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func saveState() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadState() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([ClipItem].self, from: data) {
            self.history = saved
        }
    }
}
