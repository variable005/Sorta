import Foundation
import AppKit

@MainActor
public final class PrivacyGuard {
    public static let shared = PrivacyGuard()

    private let ignoredBundleIDs: Set<String> = [
        "com.agilebits.onepassword",
        "com.agilebits.onepassword7",
        "com.1password.1password",
        "com.bitwarden.desktop",
        "com.keepassxc.keepassxc",
        "com.apple.keychainaccess"
    ]

    private var expiryTimer: Timer?

    public init() {}

    public func isFromIgnoredApplication() -> Bool {
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = frontApp.bundleIdentifier else {
            return false
        }
        return ignoredBundleIDs.contains(bundleID.lowercased())
    }

    public func isSensitiveContent(_ content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("AKIA") && trimmed.count == 20 { return true }
        if trimmed.hasPrefix("ghp_") || trimmed.hasPrefix("gho_") || trimmed.hasPrefix("github_pat_") { return true }
        if trimmed.contains("-----BEGIN ") && trimmed.contains(" PRIVATE KEY-----") { return true }
        if trimmed.hasPrefix("sk_live_") || trimmed.hasPrefix("rk_live_") { return true }
        return false
    }

    public func maskSensitiveContent(_ content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 6 else { return "******" }
        let prefix = String(trimmed.prefix(4))
        let maskedLength = trimmed.count - 4
        return prefix + String(repeating: "*", count: maskedLength)
    }

    public func scheduleAutoExpiry(seconds: TimeInterval = 30.0, onExpire: @escaping () -> Void) {
        expiryTimer?.invalidate()
        expiryTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            Task { @MainActor in
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                onExpire()
            }
        }
    }
}
