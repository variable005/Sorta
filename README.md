<p align="center">
  <img src="Assets/sorta.png" alt="SORTA Banner" width="100%" />
</p>

# SORTA

> **Smart, instant, zero-click macOS clipboard transformations & history for modern developers.**

SORTA transforms your macOS clipboard from a passive string buffer into an intelligent developer HUD. Built natively in Swift, SwiftUI, and AppKit, SORTA runs silently in the background, inspects copied text in real time, auto-detects the content type, and provides single-keystroke transformations before you paste.

---

## ⚡️ Key Features

* **Instant Developer Transformations**: Copy raw JSON, tracking URLs, cURL requests, JWT tokens, timestamps, or multi-line lists. Press `Option + Space`, press `1`–`4`, and paste transformed code directly into your editor.
* **Keyboard-First HUD**:
  * `Option + Space` — Open/Toggle HUD overlay.
  * `1`–`9` — Execute smart action and paste directly into focused app.
  * `↑` / `↓` — Navigate history items.
  * `Enter` — Paste selected item.
  * `Cmd + P` / `Cmd + S` — Toggle pin (⭐️) on selected snippet.
  * `Cmd + Backspace` — Delete item.
  * `Esc` — Dismiss HUD.
* **Persistent History & Search**: Instant fuzzy filtering with category pills (`JSON`, `cURL`, `URL`, `List / Lines`, `Pinned ⭐️`).
* **100% Local & Privacy-First**: Zero analytics, zero telemetry. Automatically ignores password managers (1Password, Bitwarden, KeePassXC, Keychain Access) and masks API keys/credentials (`AKIA...`, `ghp_...`, `sk-proj-...`).

---

## 🛠 Core Transformation Engines

| Category | Input Detection | Primary Transformations |
| :--- | :--- | :--- |
| **URL** | `http://` or `https://` URLs | Strip tracking parameters (`utm_*`, `fbclid`, `si`, `ref`), decode percent-encoding, extract domain host. |
| **JSON** | Valid JSON `{ ... }` or `[ ... ]` | Prettify (2-space indented & sorted keys), Minify, TypeScript `interface`, Swift `Codable` struct. |
| **cURL** | CLI `curl ...` command | Modern async JS `fetch()`, Python `requests`, Swift `URLSession` request. |
| **List / Lines** | Multi-line text or inline lists | Natural alphanumeric sort (A-Z), reverse sort (Z-A), unique deduplication, inline list sort. |
| **JWT** | 3-part Base64URL token | Decoded formatted Payload JSON & Header JSON. |
| **Timestamp** | 10-digit (s) or 13-digit (ms) UNIX epoch | ISO-8601 UTC timestamp, local date & time, relative time description. |
| **Color** | Hex (`#FF5733`) or `rgb(...)` | SwiftUI `Color`, AppKit `NSColor`, CSS `rgb()`, uppercase Hex. |
| **Base64** | Base64 string / plain text | Base64 decode to UTF-8 text, Base64 encode. |
| **Plain Text** | Any string content | Strip zero-width whitespace (`\u{200B}`), smart curly quotes sanitization, UPPERCASE, lowercase, Title Case. |

---

## ⌨️ Global Shortcuts & Navigation

| Keystroke | Action |
| :--- | :--- |
| **Tap `Control` 3x** / `Option + Space` | Toggle SORTA HUD |
| `1`, `2`, `3`, `4` | Select smart action & auto-paste into active app |
| `↑` / `↓` | Navigate clipboard history |
| `Enter` | Paste selected history snippet |
| `Cmd + P` / `Cmd + S` | Pin / unpin selected snippet |
| `Cmd + Backspace` | Delete selected snippet from history |
| `Esc` | Dismiss HUD overlay |

---

## 📦 Building from Source

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
