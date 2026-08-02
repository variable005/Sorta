# SORTA

Your macOS clipboard is currently a passive memory buffer storing random strings, malformed tracking links, sensitive API keys, and unformatted JSON until you paste them somewhere embarrassing.

SORTA fixes that.

SORTA is an offline native macOS menu bar and HUD application built with Swift, SwiftUI, and AppKit. It inspects whatever you copy in real-time and offers zero-click, one-key transformations before you paste it anywhere.

---

## Why SORTA Exists

Every developer on the planet repeats the same exhausting ritual ten times a day:

1. You copy a link from a friend or browser, and it comes with fifty tracking parameters attached (utm_source=twitter&utm_medium=social&si=987654321).
2. You copy a cURL command from your network tab, open a web browser, search for "curl to fetch converter", paste it into an unverified website, and copy the output back.
3. You copy a CSV from a terminal or spreadsheet and spend three minutes formatting pipe characters for a GitHub Markdown table.
4. You copy an AWS secret key or GitHub token by mistake, and it sits unencrypted in plain text in your clipboard history forever.

SORTA intercepts all of this locally on your Mac. You copy once, hit Option + Space, press 1, and paste pristine output.

---

## Features & Transformers

- **Markdown Table Generator**: Converts CSV or tab-delimited text into formatted GitHub Markdown tables (`| Header |`).
- **Base64 Data & Text Engine**: Encodes text to Base64 or decodes Base64 strings back to plain text.
- **HTML Entity Encoder/Decoder**: Decodes `&lt;div&gt;` or encodes special characters to HTML entities.
- **SQL Prettifier**: Formats raw SQL queries (`SELECT`, `JOIN`, `WHERE`) with uppercase keyword structure.
- **Regex & String Escaper**: Escapes double-quotes and backslashes for JS, Python, and Swift string literals.
- **Sequential Queue Mode**: Press Option + Shift + C to enable queue stacking. Copy multiple items in sequence, then hit Option + Shift + V to pop and paste them in order.
- **Sensitive Data & Credential Guard**: Automatically detects AWS keys, GitHub tokens, and private keys, masks them in history, and auto-expires them from pasteboard memory after 30 seconds.
- **Password Manager Exclusion**: Automatically ignores clipboard changes coming from 1Password, Bitwarden, KeePass, and Apple Keychain.
- **URL Tracking Parameter Stripper**: Automatically strips tracking query parameters (utm_*, fbclid, si, ref, gclid).
- **JSON Prettifier & Type Generator**: Formats messy JSON, minifies it, or generates TypeScript interfaces and Swift Codable structs on the fly.
- **cURL Code Converter**: Converts raw cURL commands into JavaScript fetch(), Python requests, or Swift URLSession snippets.
- **Color Converter**: Converts Hex colors (#FF5733) into SwiftUI Color, NSColor, RGB, or HSL values.
- **Timestamp Decoder**: Converts UNIX timestamps into ISO-8601 strings and local relative time descriptions.
- **100% Offline & Private**: Zero network calls, zero telemetry, zero analytics. Everything runs locally on your Mac.

---

## Usage

1. Copy any text, link, JSON, cURL, CSV, or hex color using Command + C.
2. Press Option + Space (or click the scissors icon in your menu bar) to reveal the SORTA overlay panel.
3. Press 1, 2, 3, or 4 on your keyboard to transform and paste immediately into your focused text cursor.
4. Press Option + Shift + C to toggle Sequential Queue Stacking Mode. Press Option + Shift + V to pop and paste next item in stack.

---

## Building from Source

Requirements:
- macOS 14.0 or later
- Swift 5.9 or later

Clone the repository and build:

```bash
git clone https://github.com/variable005/Sorta.git
cd Sorta
swift run
```
