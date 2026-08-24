import Foundation
import AppKit
import SwiftUI

@MainActor
public final class PanelManager: ObservableObject {
    public static let shared = PanelManager()

    @Published public private(set) var isVisible: Bool = false
    private var panel: HUDPanel?

    public init() {}

    public func configure<Content: View>(with rootView: Content) {
        let hostingView = NSHostingView(rootView: rootView)

        let newPanel = HUDPanel(
            contentRect: NSRect(x: 0, y: 0, width: 740, height: 480)
        )
        newPanel.contentView = hostingView

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

        // Find the screen currently containing the mouse cursor, fallback to main screen
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main

        if let screen = targetScreen {
            let screenRect = screen.visibleFrame
            let x = screenRect.midX - (panel.frame.width / 2)
            let y = screenRect.maxY - panel.frame.height - 80
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        // Activate panel and make it key for instant keyboard focus
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        isVisible = true
    }

    public func hidePanel() {
        guard isVisible else { return }
        panel?.orderOut(nil)
        isVisible = false
    }
}
