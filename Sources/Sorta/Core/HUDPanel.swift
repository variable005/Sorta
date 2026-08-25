import AppKit
import SwiftUI

public final class HUDPanel: NSPanel {
    public static var isDraggingActive: Bool = false

    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isMovableByWindowBackground = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    }

    public override var canBecomeKey: Bool {
        return true
    }

    public override var canBecomeMain: Bool {
        return true
    }

    public override func cancelOperation(_ sender: Any?) {
        PanelManager.shared.hidePanel()
    }

    public override func resignKey() {
        super.resignKey()
        // Do not close panel if user is actively dragging an item out of the panel!
        guard !HUDPanel.isDraggingActive else { return }
        PanelManager.shared.hidePanel()
    }
}
