<p align="center">
  <img src="Assets/sorta.png" alt="SORTA Banner" width="100%" />
</p>

# SORTA

Smart, instant, zero-click macOS clipboard inspector and developer HUD. Built natively in Swift, SwiftUI, and AppKit. Runs silently in the background, inspects clipboard contents in real time, classifies data types, formats payloads, and enables drag-and-drop file operations into active apps.

---

## Overview

| Component | Specification |
| :--- | :--- |
| **Platform** | macOS Native (AppKit + SwiftUI) |
| **Execution Model** | Background Daemon + Floating Utility Panel |
| **Activation** | Menu Bar Left Click / Triple-Tap `Control` / `Option + Space` |
| **Data Retention** | Ephemeral Local Memory Cache |
| **Telemetry** | None (Zero Analytics, Zero External Network Calls) |

---

## Capabilities

| Feature | Description |
| :--- | :--- |
| **Direct Drag and Drop** | Drag copied images straight out of the panel into Finder, Figma, Slack, Discord, Chrome, VS Code, or Notes. Automatically packages PNG, TIFF, and file URL representations. |
| **Instant Inspection** | Automatic payload analysis for JSON, URLs, Colors, JWT tokens, UNIX Timestamps, and Images without manual triggering. |
| **History Drawer** | Collapsible sidebar drawer with category filtering, search querying, and item previews. |
| **One-Click Actions** | Dedicated copy and paste buttons with instant visual feedback and smooth spring animations. |
| **Privacy Protection** | Password managers are ignored automatically; sensitive credentials, private tokens, and API keys are masked before display. |

---

## Data Handlers and Transformations

| Category | Input Criteria | Output / Features |
| :--- | :--- | :--- |
| **Image** | System Pasteboard Image Data | Aspect-fitted preview, direct AppKit drag-and-drop export, multi-format drop support (`public.png`, `TIFF`, file URL). |
| **JSON** | `{ ... }` or `[ ... ]` payloads | Formatted 2-space indented hierarchy, sorted key structure, syntax validation, raw view toggle. |
| **URL** | `http://` / `https://` schemes | Parsed domain host, path breakdown, isolated query parameter table, tracking parameter sanitization. |
| **Color** | Hex `#RRGGBB`, `rgb(...)` strings | Live interactive color preview tile, instant conversions to HEX, RGB, and SwiftUI `Color` declarations. |
| **Timestamp** | 10-digit (s) or 13-digit (ms) UNIX epoch | Human-readable full date, localized time, relative elapsed time indicator, raw epoch value. |
| **JWT** | 3-part Base64URL dot-separated token | Decoded payload claims, formatted header JSON, expiry inspection. |
| **Plain Text** | Generic string data | Clean typography presentation, monospaced formatting where appropriate, whitespace cleanup. |

---

## Controls and Shortcuts

| Keystroke / Gesture | Context | Action |
| :--- | :--- | :--- |
| **Menu Bar Left Click** | Menu Bar | Toggle HUD Panel immediately |
| **Menu Bar Right Click** | Menu Bar | Open Context Menu (Settings, Quit) |
| **Tap `Control` 3x** | Global | Toggle HUD Panel |
| **`Option + Space`** | Global | Toggle HUD Panel |
| **`Tab`** | HUD Active | Toggle History Drawer |
| **`↑` / `↓`** | HUD Active | Navigate items in History |
| **`Return`** | HUD Active | Paste selected item into active application |
| **`Esc`** | HUD Active | Dismiss HUD Panel |
| **Click and Drag** | Image Preview | Drag image into other applications or Finder |

---

## Architecture

| Layer | Technology | Function |
| :--- | :--- | :--- |
| **Watcher Engine** | AppKit `NSPasteboard` | Polling change count listener with debounce and sensitive app filtering. |
| **HUD Window** | `NSPanel` | Floating non-activating transparent utility window with visual effect backing. |
| **Renderer** | SwiftUI | Reactive view hierarchy driven by state observables. |
| **Drag Engine** | `NSDraggingSource` | Custom AppKit dragging session with multi-type pasteboard registration. |
| **Transformers** | Swift Engine | Pure deterministic transformation pipelines for URLs, JSON, JWT, and timestamps. |

---

## Security and Privacy

| Area | Policy |
| :--- | :--- |
| **Password Managers** | Automatically ignores copies originating from 1Password, Bitwarden, KeePassXC, and Keychain Access. |
| **Secret Masking** | Pattern matching for AWS credentials (`AKIA...`), GitHub Personal Access Tokens (`ghp_...`), OpenAI API keys (`sk-...`), and private keys. |
| **Local Isolation** | All parsing and formatting occur strictly on-device in memory. No network connections are initiated. |

---

a project by hariom sharnam
