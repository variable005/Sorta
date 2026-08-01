# SORTA

Your macOS clipboard is currently a passive memory buffer storing random strings, malformed tracking links, and unformatted JSON until you paste them somewhere embarrassing.

SORTA fixes that.

SORTA is an offline native macOS menu bar and HUD application built with Swift, SwiftUI, and AppKit. It inspects whatever you copy in real-time and offers zero-click, one-key transformations before you paste it anywhere.

---

## Why SORTA Exists

Every developer on the planet repeats the same exhausting ritual ten times a day:

1. You copy a link from a friend or browser, and it comes with fifty tracking parameters attached (utm_source=twitter&utm_medium=social&si=987654321).
2. You copy a cURL command from your network tab, open a web browser, search for "curl to fetch converter", paste it into an unverified website, and copy the output back.
3. You copy a raw JSON string from a terminal log, open another browser tab for "JSON formatter", format it, and generate a TypeScript interface.
4. You copy a UNIX timestamp like 1754034807 and have to ask your search engine what year that actually is.

SORTA intercepts all of this locally on your Mac. You copy once, hit Option + Space, press 1, and paste pristine output.

---

## Features

- **URL Tracking Parameter Stripper**: Automatically strips tracking query parameters (utm_*, fbclid, si, ref, gclid) so you never send bloated URLs again.
- **JSON Prettifier & Type Generator**: Instantly formats messy JSON, minifies it, or generates TypeScript interfaces and Swift Codable structs on the fly.
- **cURL Code Converter**: Converts raw curl terminal commands into clean JavaScript fetch(), Python requests, or Swift URLSession snippets.
- **Color Converter**: Converts Hex colors (#FF5733) into SwiftUI Color, NSColor, RGB, or HSL values.
- **Timestamp Decoder**: Converts UNIX timestamps into ISO-8601 strings, human-readable local dates, and relative time descriptions.
- **JWT Inspector**: Decodes JWT headers and payload claims instantly without pasting secret tokens onto external websites.
- **Text & Whitespace Sanitizer**: Strips hidden zero-width spaces, cleans smart-quotes, and normalizes messy formatting.
- **100% Offline & Private**: Zero network calls, zero telemetry, zero analytics. Everything runs locally on your Mac.

---

## Usage

1. Copy any text, link, JSON, cURL, or hex color using Command + C.
2. Press Option + Space (or click the scissors icon in your menu bar) to reveal the SORTA overlay panel.
3. Press 1, 2, 3, or 4 on your keyboard to transform and paste immediately into your focused text cursor.

