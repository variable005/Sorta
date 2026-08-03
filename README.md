# SORTA

> **Smart, instant, zero-click macOS clipboard transformations.**

SORTA transforms your macOS clipboard from a passive string buffer into an intelligent developer workspace. Built natively for macOS using Swift, SwiftUI, and AppKit, SORTA runs silently in your menu bar, inspects copied text in real time, and provides single-keystroke transformations before you paste.

---

## ⚡ Why SORTA?

Developers spend hours every day performing repetitive clipboard micro-tasks:

1. **Unsanitized URLs**: Copying links laden with tracking telemetry (`utm_source`, `fbclid`, `si`, `gclid`).
2. **Web Tool Roundtrips**: Navigating to unverified online converters just to format JSON, decode JWTs, or convert cURL commands.
3. **Markdown Overhead**: Formatting raw CSV/TSV data into GitHub Markdown tables by hand.
4. **Clipboard Security**: Leaving AWS keys, GitHub tokens, or private keys unencrypted in clipboard memory.

**SORTA solves all of this locally on your Mac.** Copy text, press `Option + Space`, hit `1`–`4`, and paste formatted output instantly.

---

## ✨ Features & Transformers

SORTA includes **12 specialized transformation engines** out of the box:

| Category | Transformer | Features |
| :--- | :--- | :--- |
| **JSON** | **JSON Prettifier & Type Generator** | Pretty-print, minify JSON, or auto-generate TypeScript interfaces and Swift `Codable` structs on the fly. |
| **cURL** | **cURL Code Converter** | Converts raw cURL CLI commands into executable JavaScript `fetch()`, Python `requests`, or Swift `URLSession` snippets. |
| **SQL** | **SQL Prettifier** | Formats raw SQL queries (`SELECT`, `FROM`, `WHERE`, `JOIN`) into clean, uppercase structured syntax. |
| **Markdown** | **Markdown Table Generator** | Transforms raw CSV or tab-delimited text into formatted GitHub Flavored Markdown tables. |
| **JWT** | **JWT Decoder & Inspector** | Automatically detects JWT tokens and decodes Header and Payload contents into formatted JSON objects. |
| **Security** | **Text Sanitizer & Case Tools** | Strips zero-width space characters, normalizes smart quotes, flattens text into single line, and converts case (UPPERCASE, lowercase, Title Case). |
| **URLs** | **URL Parameter Cleaner** | Strips tracking query parameters (`utm_*`, `fbclid`, `gclid`, `si`, `ref`) while preserving clean links. |
| **Base64** | **Base64 Data Engine** | Encodes plain text to Base64 or decodes valid Base64 strings back to UTF-8 text. |
| **HTML** | **HTML Entity Engine** | Decodes HTML entities (`&lt;div&gt;`) to plain text or encodes special characters to HTML entities. |
| **Regex** | **Regex & String Escaper** | Escapes double-quotes and backslashes for safe inclusion in JS, Python, and Swift string literals. |
| **Color** | **Color Converter** | Converts Hex hex codes (`#FF5733`) into SwiftUI `Color`, NSColor, RGB, or HSL values. |
| **Time** | **Timestamp Decoder** | Converts UNIX epoch timestamps (seconds/ms) into ISO-8601 strings and human-readable relative time. |

---

## 🔒 Privacy & Credential Guard

SORTA is built offline-first with security as a core primitive:

- **100% Local & Offline**: Zero network calls, zero tracking, zero telemetry.
- **Sensitive Credential Detection**: Automatically identifies AWS keys (`AKIA...`), GitHub PATs (`ghp_`, `github_pat_`), PEM Private Keys, and Stripe live keys (`sk_live_`).
- **Auto-Masking**: Sensitive tokens are masked in clipboard previews (`AKIA****************`).
- **Auto-Expiry**: Purges sensitive credentials from system clipboard memory after 30 seconds.
- **Password Manager Exclusion**: Automatically ignores clipboard updates originating from **1Password**, **Bitwarden**, **KeePassXC**, and **Keychain Access**.

---

## 🔁 Sequential Queue Stacking Mode

SORTA allows you to copy multiple snippets in sequence and paste them one by one:

1. Press `Option + Shift + C` to enable **Queue Stacking Mode**.
2. Copy multiple items from various sources using `Command + C`.
3. Press `Option + Shift + V` to pop and paste each queued item in order into your active cursor.

---

## ⌨️ Global Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Option + Space` | Toggle SORTA HUD Overlay |
| `1`, `2`, `3`, `4` | Select transformation option & auto-paste into focused application |
| `Option + Shift + C` | Toggle Sequential Queue Stacking Mode |
| `Option + Shift + V` | Pop & paste next item from Sequential Queue |

---

## 🛠️ Building from Source

### Requirements
- **macOS**: 14.0 (Sonoma) or later
- **Swift**: 5.9 or later / Xcode 15+

### Build & Run

```bash
# Clone the repository
git clone https://github.com/variable005/Sorta.git
cd Sorta

# Build the project
swift build

# Run SORTA
swift run
```

---

## 📜 License

MIT License. Free and open-source software.
