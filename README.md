<p align="center">
  <img src="Assets/sorta.png" alt="SORTA Banner" width="100%" />
</p>

# SORTA

> **Smart, instant, zero-click macOS clipboard transformations & intelligent categorization for modern developers.**

SORTA transforms your macOS clipboard from a passive string buffer into an intelligent developer workspace. Built natively for macOS using Swift, SwiftUI, and AppKit, SORTA runs silently in your menu bar, inspects copied text in real time, automatically categorizes the input type, and provides single-keystroke transformations before you paste.

---

## Table of Contents

- [Why SORTA?](#why-sorta)
- [Content Categorization Architecture](#content-categorization-architecture)
  - [Domain Categorization Groups](#domain-categorization-groups)
  - [Categorization Matrix & Detection Rules](#categorization-matrix--detection-rules)
- [Transformation Engines](#transformation-engines)
  - [🛠 Developer Data Engines](#-developer-data-engines)
    - [JSON Prettifier & Type Generator](#json-prettifier--type-generator)
    - [cURL Code Converter](#curl-code-converter)
    - [SQL Query Prettifier](#sql-query-prettifier)
    - [JWT Decoder & Inspector](#jwt-decoder--inspector)
  - [🌐 Web & Encoding Engines](#-web--encoding-engines)
    - [URL Parameter Cleaner & Canonicalizer](#url-parameter-cleaner--canonicalizer)
    - [Base64 Data Engine](#base64-data-engine)
    - [HTML Entity Engine](#html-entity-engine)
  - [📝 Text & Formatting Engines](#-text--formatting-engines)
    - [Line & List Sorter](#line--list-sorter)
    - [Markdown Table Generator](#markdown-table-generator)
    - [Regex & String Escaper](#regex--string-escaper)
    - [Text Sanitizer & Case Tools](#text-sanitizer--case-tools)
  - [🎨 Design & Utility Engines](#-design--utility-engines)
    - [Color Code Converter](#color-code-converter)
    - [Timestamp Decoder](#timestamp-decoder)
- [Privacy & Credential Guard](#privacy--credential-guard)
- [Sequential Queue Stacking Mode](#sequential-queue-stacking-mode)
- [Global Shortcuts](#global-shortcuts)
- [Building from Source](#building-from-source)

---

## Why SORTA?

Developers spend hours every day performing repetitive clipboard micro-tasks:

1. **Unsanitized URLs**: Copying links laden with tracking telemetry (`utm_source`, `fbclid`, `si`, `gclid`).
2. **Web Tool Roundtrips**: Navigating to unverified online converters just to format JSON, decode JWTs, or convert cURL commands.
3. **Markdown Overhead**: Formatting raw CSV/TSV data into GitHub Markdown tables by hand.
4. **Manual List & Line Sorting**: Alphabetizing imports, environment variables, or log lines manually.
5. **Clipboard Security**: Leaving AWS keys, GitHub tokens, or private keys unencrypted in clipboard memory.

**SORTA solves all of this locally on your Mac.** Copy text, press `Option + Space`, hit `1`–`5`, and paste formatted output instantly.

---

## Content Categorization Architecture

SORTA features a zero-latency, real-time pattern matching engine (`TransformerRegistry`) that analyzes clipboard contents as soon as you hit `Cmd + C`. 

Rather than presenting generic text options, SORTA **categorizes copied content into 13 distinct type classifications** paired with dedicated SF Symbol visual indicators and tailored action shortcuts in the HUD overlay and history viewer.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        COPIED CLIPBOARD TEXT                           │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                        ┌───────────▼───────────┐
                        │  TransformerRegistry  │ (Pattern Matching)
                        └───────────┬───────────┘
                                    │
   ┌────────────────────────────────┴────────────────────────────────┐
   │                                                                 │
┌──▼──────────────────────────┐                   ┌──────────────────▼──────────┐
│  Domain Categorization      │                   │ 13 Native Clip Categories   │
├─────────────────────────────┤                   ├─────────────────────────────┤
│ 🛠 Developer Data           │                   │ • JSON (`curlybraces`)      │
│ 🌐 Web & Encoding           │                   │ • cURL (`terminal`)         │
│ 📝 Text & Structuring       │                   │ • SQL Query (`database`)    │
│ 🎨 Design & Utilities       │                   │ • JWT Token (`key`)         │
└─────────────────────────────┘                   │ • URL (`link`)              │
                                                  │ • Base64 (`lock.rectangle`) │
                                                  │ • HTML Entity (`chevron...`)│
                                                  │ • Line Sorter (`arrow...`)  │
                                                  │ • Markdown (`tablecells`)   │
                                                  │ • Regex (`asterisk`)        │
                                                  │ • Text (`doc.text`)         │
                                                  │ • Color (`paintpalette`)    │
                                                  │ • Timestamp (`clock`)       │
                                                  └─────────────────────────────┘
```

### Domain Categorization Groups

The 13 categories are organized across **4 primary functional domains**:

1. **🛠 Developer Data Engines**: Structured payloads, API requests, database queries, and identity tokens.
2. **🌐 Web & Encoding Engines**: Web URLs, tracking query parameters, Base64 binaries, and HTML escape entities.
3. **📝 Text & Formatting Engines**: Multi-line list sorting, raw tabular data, regex escape strings, case shifts, and zero-width unicode sanitization.
4. **🎨 Design & Utility Engines**: Hex/RGB color code transformations for SwiftUI/AppKit/CSS, and UNIX epoch timestamp conversions.

---

### In-App Auto-Sorting & Category Filtering

SORTA automatically sorts and categorizes copied materials across multiple UI surfaces:

- **Category Filter Pills Bar**: Filter your clipboard history with one click using interactive category pills (`All`, `JSON`, `cURL`, `SQL`, `URL`, `Color`, etc.) showing real-time item counts.
- **Auto-Grouped Category View**: Toggle between **Recent Chronological** list view and **By Category** grouped view that automatically sorts copied items into domain headers (`DEVELOPER DATA`, `WEB & ENCODING`, etc.).
- **macOS Menu Bar Categorized Submenus**: Access your copied materials auto-sorted into category submenus directly from the macOS status bar menu without bringing up the main HUD.
- **Domain Category Badges**: Every clipboard entry in the HUD displays its primary category icon alongside its parent domain badge.

---


### Categorization Matrix & Detection Rules

Below is the complete categorization taxonomy showing how SORTA detects clipboard content:

| Category | SF Symbol | Detection Trigger / Pattern Rule | Primary Output Transformations |
| :--- | :--- | :--- | :--- |
| **JSON** | `curlybraces` | Starts with `{` or `[` and validates as valid JSON object or array. | Prettify 2-space, Minify, TS Interface, Swift `Codable` Struct. |
| **cURL** | `terminal` | Starts with `curl ` (case-insensitive CLI command). | JS `fetch()`, Python `requests`, Swift `URLSession`. |
| **SQL Query** | `database` | Starts with `SELECT`, `INSERT INTO`, `UPDATE`, or `DELETE FROM`. | Uppercase keyword formatting & clause newline splitting. |
| **JWT Token** | `key` | 3 dot-separated Base64URL strings with valid JSON Header/Payload. | Formatted Decoded Payload JSON & Decoded Header JSON. |
| **URL** | `link` | Valid `http://` or `https://` URL string with host. | Strip tracking parameters (`utm_*`, `fbclid`), Canonical query sorting, Domain extraction. |
| **Base64** | `lock.rectangle` | Valid Base64 characters (length ≥ 8, multiple of 4) decoding to valid UTF-8. | Decode Base64 to Plain Text, Encode Text to Base64. |
| **HTML Entity** | `chevron.left.slash.chevron.right` | Contains encoded entities (`&lt;`, `&gt;`, `&amp;`, `&quot;`, `&#39;`). | Decode HTML Entities to raw text, Encode special characters to HTML entities. |
| **Line & List Sorter** | `arrow.up.arrow.down` | Multi-line text (≥ 2 lines) or inline delimited list (3+ items with `,`, `;`, `|`). | Natural A-Z, Reverse Z-A, Deduplicate Unique, Length Sort, Numeric Sort, Delimited List Sort. |
| **Markdown Table** | `tablecells` | 2+ tabular lines separated by commas (CSV with quotes) or tabs (TSV). | Format GitHub Markdown Table, Alphabetical Row Sort (A-Z). |
| **Regex** | `asterisk` | Wrapped in slashes (`/.../`) or contains regex tokens (`\d`, `\w`, `\s`). | Escape String Literals (JS/Python/Swift), Swift Raw String (`#"..."#`). |
| **Color** | `paintpalette` | Valid 6-digit Hex code (`#FF5733` / `FF5733`) or `rgb(r,g,b)` tuple. | SwiftUI `Color`, AppKit `NSColor`, CSS `rgb()`, Normalized Hex. |
| **Timestamp** | `clock` | 10-digit (seconds) or 13-digit (ms) UNIX epoch timestamp. | ISO-8601 UTC string, Full Local Date & Time, Relative time ("2 hours ago"). |
| **Plain Text** | `doc.text` | Fallback for any non-empty text string. | Zero-width space sanitization, Single line compact, UPPERCASE, lowercase, Title Case. |

---

## Transformation Engines

### 🛠 Developer Data Engines

#### JSON Prettifier & Type Generator
- **Prettify JSON**: 2-space indented JSON formatting with alphabetically sorted dictionary keys.
- **Minify JSON**: Single-line compact JSON representation.
- **TypeScript Interface Generation**: Auto-generates `interface GeneratedType { ... }` with typed fields and sorted property keys.
- **Swift Codable Struct Generation**: Auto-generates Swift `struct GeneratedItem: Codable { ... }` with native Swift types (`Int`, `Double`, `Bool`, `String`).

#### cURL Code Converter
- **JavaScript `fetch()`**: Converts CLI cURL requests into modern `async/await` fetch code snippets.
- **Python `requests`**: Generates Python `requests.request()` code with header and payload dictionaries.
- **Swift `URLSession`**: Generates native async Swift `URLRequest` code.
- **Deterministic Header Ordering**: Header keys are sorted alphabetically for predictable, diff-friendly output.

#### SQL Query Prettifier
- **Keyword Standardization**: Converts SQL keywords (`SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`, `ORDER BY`, `HAVING`, `LIMIT`) into standard uppercase syntax.
- **Clause Linebreaks**: Places major query clauses (`FROM`, `WHERE`, `JOIN`, etc.) on clean newlines for enhanced readability.

#### JWT Decoder & Inspector
- **Decoded Payload JSON**: Decodes the Base64URL payload segment of JWT tokens into formatted 2-space indented JSON.
- **Decoded Header JSON**: Decodes the Base64URL header segment (algorithm & token type) into clean JSON.

---

### 🌐 Web & Encoding Engines

#### URL Parameter Cleaner & Canonicalizer
- **Clean Tracking Parameters**: Strips tracking telemetry (`utm_source`, `utm_medium`, `utm_campaign`, `fbclid`, `gclid`, `si`, `ref`) while preserving core paths and params.
- **Sort Query Parameters**: Alphabetically sorts URL query parameters to produce canonical, comparable URL strings.
- **Decode Percent-Encoding**: Replaces URL escape sequences (`%20` → space, `%3A` → `:`) with clean text.
- **Extract Host/Domain**: Isolates the domain name host from complex URL strings.

#### Base64 Data Engine
- **Decode Base64**: Decodes valid Base64 encoded strings back into readable UTF-8 text.
- **Encode Base64**: Encodes raw text strings into Base64 output.

#### HTML Entity Engine
- **Decode HTML Entities**: Converts entities (`&lt;`, `&gt;`, `&amp;`, `&quot;`, `&#39;`, `&nbsp;`) back into raw characters (`<`, `>`, `&`, `"`, `'`, ` `).
- **Encode HTML Entities**: Escapes special HTML characters into standard web entity representations.

---

### 📝 Text & Formatting Engines

#### Line & List Sorter
- **Sort Lines (A-Z Natural)**: Orders multi-line lists in natural numerical order (`item2` precedes `item10`).
- **Sort Lines (Z-A Reverse)**: Sorts multi-line text in reverse natural alphabetical order.
- **Sort & Deduplicate (Unique A-Z)**: Strips duplicate lines case-insensitively and sorts the unique remaining lines.
- **Sort by Line Length**: Orders lines from shortest to longest with natural tie-breaking.
- **Sort Numerically**: Extracts embedded numeric values from each line and sorts by numerical value.
- **Sort Delimited List**: Alphabetizes inline single-line lists separated by commas (`,`), semicolons (`;`), or pipes (`|`).
- **Zero-Width Unicode Sanitization**: Automatically strips invisible characters (`\u{200B}`, `\u{FEFF}`) and normalizes line endings (`\r\n` / `\r` → `\n`).

#### Markdown Table Generator
- **CSV & TSV Parsing**: Transforms raw comma-separated or tab-delimited tabular data into aligned GitHub Flavored Markdown tables.
- **Quote-Aware CSV Handling**: Accurately respects commas inside double quotes (e.g. `"Doe, Jane", 28`).
- **Sort Table Rows**: Alphabetizes table data rows by Column 1 while preserving the header row.

#### Regex & String Escaper
- **Escape String Literal**: Escapes backslashes and double quotes (`"` → `\"`, `\` → `\\`) for safe pasting into JS, Python, and Swift string variables.
- **Swift Raw String**: Wraps text in Swift raw string literal syntax (`#"..."#`).

#### Text Sanitizer & Case Tools
- **Sanitize Text & Whitespace**: Strips hidden Unicode zero-width space characters (`\u{200B}`, `\u{200C}`, `\u{200D}`, `\u{FEFF}`) and replaces smart curly quotes (`“”‘’`) with standard quotes (`""''`).
- **Single Line Compact**: Flattens multi-line paragraphs into a clean single-line string with normalized single spaces.
- **Case Transformations**: Provides single-click conversion to `UPPERCASE`, `lowercase`, and `Title Case`.

---

### 🎨 Design & Utility Engines

#### Color Code Converter
- **SwiftUI Color**: Generates `Color(red: 0.000, green: 0.000, blue: 0.000)` initialization code.
- **AppKit NSColor**: Generates `NSColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)` code.
- **CSS RGB Tuple**: Outputs standard `rgb(r, g, b)` CSS color strings.
- **Hex Color String**: Normalizes inputs into uppercase 6-digit hex color strings (`#FF5733`).

#### Timestamp Decoder
- **ISO-8601 UTC String**: Converts UNIX epoch timestamps (seconds or milliseconds) into standardized ISO-8601 strings (`2023-11-14T22:13:20Z`).
- **Local Date & Time String**: Converts epoch values into full human-readable local date and time strings.
- **Relative Time Description**: Calculates relative time offsets (e.g. "2 hours ago", "in 3 days").

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
