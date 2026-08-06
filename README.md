<p align="center">
  <img src="Assets/sorta_banner.png" alt="SORTA Banner" width="100%" />
</p>

# SORTA

> **Smart, instant, zero-click macOS clipboard transformations for modern developers.**

SORTA transforms your macOS clipboard from a passive string buffer into an intelligent developer workspace. Built natively for macOS using Swift, SwiftUI, and AppKit, SORTA runs silently in your menu bar, inspects copied text in real time, and provides single-keystroke transformations before you paste.

---

## Table of Contents

- [Why SORTA?](#why-sorta)
- [Transformation Engines](#transformation-engines)
  - [Line & List Sorter](#line--list-sorter)
  - [JSON Prettifier & Type Generator](#json-prettifier--type-generator)
  - [URL Parameter Cleaner & Canonicalizer](#url-parameter-cleaner--canonicalizer)
  - [cURL Code Converter](#curl-code-converter)
  - [Markdown Table Generator](#markdown-table-generator)
  - [JWT Decoder & Inspector](#jwt-decoder--inspector)
  - [SQL Query Prettifier](#sql-query-prettifier)
  - [Text Sanitizer & Case Tools](#text-sanitizer--case-tools)
  - [Base64 Data Engine](#base64-data-engine)
  - [HTML Entity Engine](#html-entity-engine)
  - [Regex & String Escaper](#regex--string-escaper)
  - [Color Code Converter](#color-code-converter)
  - [Timestamp Decoder](#timestamp-decoder)
- [Privacy & Credential Guard](#privacy--credential-guard)
- [Sequential Queue Stacking Mode](#sequential-queue-stacking-mode)
- [Global Shortcuts](#global-shortcuts)
- [Building from Source](#building-from-source)
- [License](#license)

---

## Why SORTA?

Developers spend hours every day performing repetitive clipboard micro-tasks:

1. **Unsanitized URLs**: Copying links laden with tracking telemetry (`utm_source`, `fbclid`, `si`, `gclid`).
2. **Web Tool Roundtrips**: Navigating to unverified online converters just to format JSON, decode JWTs, or convert cURL commands.
3. **Markdown Overhead**: Formatting raw CSV/TSV data into GitHub Markdown tables by hand.
4. **Manual List & Line Sorting**: Alphabetizing imports, environment variables, or log lines manually.
5. **Clipboard Security**: Leaving AWS keys, GitHub tokens, or private keys unencrypted in clipboard memory.

**SORTA solves all of this locally on your Mac.** Copy text, press `Option + Space`, hit `1`–`4`, and paste formatted output instantly.

---

## Transformation Engines

SORTA includes **13 specialized transformation engines** out of the box:

| Category | Transformer | Summary |
| :--- | :--- | :--- |
| **Sorting** | [**Line & List Sorter**](#line--list-sorter) | Natural numerical line sorting (A-Z, Z-A), unique deduplication, line length sorting, numeric sorting, and inline list sorting. |
| **JSON** | [**JSON Prettifier & Type Generator**](#json-prettifier--type-generator) | Pretty-print, minify JSON, or auto-generate TypeScript interfaces and Swift `Codable` structs from objects or arrays. |
| **URLs** | [**URL Parameter Cleaner & Canonicalizer**](#url-parameter-cleaner--canonicalizer) | Strips tracking query parameters (`utm_*`, `fbclid`, `si`) and canonicalizes parameter order alphabetically. |
| **cURL** | [**cURL Code Converter**](#curl-code-converter) | Converts raw cURL CLI commands into executable JavaScript `fetch()`, Python `requests`, or Swift `URLSession` snippets with sorted headers. |
| **Markdown** | [**Markdown Table Generator**](#markdown-table-generator) | Transforms raw CSV (with quote handling) or tab-delimited text into formatted GitHub Markdown tables, with optional row sorting. |
| **JWT** | [**JWT Decoder & Inspector**](#jwt-decoder--inspector) | Automatically detects JWT tokens and decodes Header and Payload contents into formatted JSON objects. |
| **SQL** | [**SQL Query Prettifier**](#sql-query-prettifier) | Formats raw SQL queries (`SELECT`, `FROM`, `WHERE`, `JOIN`) into clean, uppercase structured syntax. |
| **Security** | [**Text Sanitizer & Case Tools**](#text-sanitizer--case-tools) | Strips zero-width space characters, normalizes smart quotes, flattens text into single line, and converts case. |
| **Base64** | [**Base64 Data Engine**](#base64-data-engine) | Encodes plain text to Base64 or decodes valid Base64 strings back to UTF-8 text. |
| **HTML** | [**HTML Entity Engine**](#html-entity-engine) | Decodes HTML entities (`&lt;div&gt;`) to plain text or encodes special characters to HTML entities. |
| **Regex** | [**Regex & String Escaper**](#regex--string-escaper) | Escapes double-quotes and backslashes for safe inclusion in JS, Python, and Swift string literals. |
| **Color** | [**Color Code Converter**](#color-code-converter) | Converts Hex codes (`#FF5733`) into SwiftUI `Color`, NSColor, RGB, or HSL values. |
| **Time** | [**Timestamp Decoder**](#timestamp-decoder) | Converts UNIX epoch timestamps (seconds/ms) into ISO-8601 strings and human-readable relative time. |

---

### Line & List Sorter

The **Line & List Sorter** transforms multi-line clipboard inputs and comma-separated inline lists with high-performance natural sorting:

- **Sort Lines (A-Z Natural)**: Natural numerical order (`item2` sorts before `item10`).
- **Sort Lines (Z-A Reverse)**: Descending natural alphabetical order.
- **Sort & Deduplicate (Unique A-Z)**: Removes duplicate lines case-insensitively and sorts remaining lines.
- **Sort by Line Length**: Orders lines from shortest to longest with natural tie-breaking.
- **Sort Numerically**: Extracts embedded numeric values from lines and orders them value-wise.
- **Sort Delimited List**: Alphabetizes inline lists delimited by `,`, `;`, or `|`.
- **Line Ending & Zero-Width Sanitization**: Normalizes `\r\n` / `\r` line breaks and strips hidden Unicode zero-width space characters (`\u{200B}`, `\u{FEFF}`).

---

### JSON Prettifier & Type Generator

- **Prettify JSON**: 2-space indented JSON formatting with sorted dictionary keys.
- **Minify JSON**: Single line compact JSON representation.
- **TypeScript Interface Generation**: Converts JSON objects or JSON Arrays (`[Any]`) into `interface GeneratedType { ... }` with naturally sorted properties.
- **Swift Codable Struct Generation**: Auto-generates `struct GeneratedItem: Codable { ... }` with Swift type mappings.

---

### URL Parameter Cleaner & Canonicalizer

- **Clean Tracking Parameters**: Strips `utm_source`, `utm_medium`, `utm_campaign`, `fbclid`, `gclid`, `si`, `ref`, and other telemetry parameters while preserving path and query structure.
- **Sort Query Parameters (Canonical URL)**: Alphabetically sorts URL query parameters for canonical query comparisons.
- **Decode Percent-Encoding**: Restores URL-encoded characters (`%20` → space) to readable text.
- **Extract Host/Domain**: Pulls the clean domain host from complex URLs.

---

### cURL Code Converter

- **JavaScript `fetch()`**: Generates modern `async/await` fetch snippets with sorted headers.
- **Python `requests`**: Generates idiomatic Python code with headers and payload dictionaries.
- **Swift `URLSession`**: Generates native async Swift `URLRequest` code.
- **Header Order Determinism**: Sorts header keys alphabetically to produce deterministic, reproducible code.

---

### Markdown Table Generator

- **Convert CSV/TSV**: Parses comma and tab-delimited text into aligned GitHub Flavored Markdown tables.
- **CSV Quote Support**: Accurately handles commas enclosed inside quotes (e.g. `"Doe, Jane", 28`).
- **Sort Table Rows (A-Z)**: Alphabetizes data rows by Column 1 while preserving table headers.

---

## Privacy & Credential Guard

SORTA is built offline-first with security as a core primitive:

- **100% Local & Offline**: Zero network calls, zero tracking, zero telemetry.
- **Sensitive Credential Detection**: Automatically identifies AWS keys (`AKIA...`), GitHub PATs (`ghp_`, `github_pat_`), PEM Private Keys, and Stripe live keys (`sk_live_`).
- **Auto-Masking**: Sensitive tokens are masked in clipboard previews (`AKIA****************`).
- **Auto-Expiry**: Purges sensitive credentials from system clipboard memory after 30 seconds.
- **Password Manager Exclusion**: Automatically ignores clipboard updates originating from **1Password**, **Bitwarden**, **KeePassXC**, and **Keychain Access**.

---

## Sequential Queue Stacking Mode

SORTA allows you to copy multiple snippets in sequence and paste them one by one:

1. Press `Option + Shift + C` to enable **Queue Stacking Mode**.
2. Copy multiple items from various sources using `Command + C`.
3. Press `Option + Shift + V` to pop and paste each queued item in order into your active cursor.

---

## Global Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Option + Space` | Toggle SORTA HUD Overlay |
| `1`, `2`, `3`, `4`, `5` | Select transformation option & auto-paste into focused application |
| `Option + Shift + C` | Toggle Sequential Queue Stacking Mode |
| `Option + Shift + V` | Pop & paste next item from Sequential Queue |

---

## Building from Source

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

## License

MIT License. Free and open-source software.
