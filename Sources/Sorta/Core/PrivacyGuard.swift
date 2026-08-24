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
    private var pendingSensitiveContent: String?

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

        // AWS Access Key
        if trimmed.hasPrefix("AKIA") && trimmed.count == 20 { return true }

        // GitHub Tokens
        if trimmed.hasPrefix("ghp_") || trimmed.hasPrefix("gho_") || trimmed.hasPrefix("github_pat_") { return true }

        // Stripe Live Keys
        if trimmed.hasPrefix("sk_live_") || trimmed.hasPrefix("rk_live_") { return true }

        // OpenAI & Anthropic Keys
        if trimmed.hasPrefix("sk-proj-") || trimmed.hasPrefix("sk-ant-") { return true }

        // Slack Tokens
        if trimmed.hasPrefix("xoxb-") || trimmed.hasPrefix("xoxp-") || trimmed.hasPrefix("xapp-") { return true }

        // Google API Keys
        if trimmed.hasPrefix("AIzaSy") && trimmed.count == 39 { return true }

        // PEM Private Keys
        if trimmed.contains("-----BEGIN ") && trimmed.contains("PRIVATE KEY-----") { return true }

        return false
    }

    public func maskSensitiveContent(_ content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 6 else { return "******" }
        let prefix = String(trimmed.prefix(4))
        let maskedLength = trimmed.count - 4
        return prefix + String(repeating: "*", count: maskedLength)
    }

    public func scheduleAutoExpiry(for content: String, seconds: TimeInterval = 30.0, onExpire: @escaping () -> Void) {
        expiryTimer?.invalidate()
        pendingSensitiveContent = content

        expiryTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                let pasteboard = NSPasteboard.general
                // Only clear if the pasteboard still contains the sensitive item!
                if pasteboard.string(forType: .string) == self.pendingSensitiveContent {
                    pasteboard.clearContents()
                    onExpire()
                }
                self.pendingSensitiveContent = nil
            }
        }
    }
}
