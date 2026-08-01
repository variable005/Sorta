import Foundation
import AppKit
import SwiftUI

@MainActor
public final class PanelManager: ObservableObject {
    public static let shared = PanelManager()

    @Published public private(set) var isVisible: Bool = false
    private var panel: NSPanel?

    public init() {}

    public func configure<Content: View>(with rootView: Content) {
        let hostingView = NSHostingView(rootView: rootView)

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        newPanel.level = .floating
        newPanel.isOpaque = false
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = true
        newPanel.contentView = hostingView
        newPanel.isMovableByWindowBackground = true

        self.panel = newPanel
    }

    public func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    public func showPanel() {
        guard let panel = panel else { return }

        // Position panel in the upper-center of the active screen
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let x = screenRect.midX - (panel.frame.width / 2)
            let y = screenRect.maxY - panel.frame.height - 80
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.orderFrontRegardless()
        isVisible = true
    }

    public func hidePanel() {
        panel?.orderOut(nil)
        isVisible = false
    }
}
