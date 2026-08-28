import SwiftUI

public struct FunnyMessage: Identifiable, Equatable {
    public let id: UUID
    public let headline: String
    public let subtext: String
    public let icon: String
    public let badge: String
    public let gradientColors: [Color]
    public let tipShortcut: String?

    public init(
        id: UUID = UUID(),
        headline: String,
        subtext: String,
        icon: String,
        badge: String,
        gradientColors: [Color] = [.cyan, .blue],
        tipShortcut: String? = "⌘C"
    ) {
        self.id = id
        self.headline = headline
        self.subtext = subtext
        self.icon = icon
        self.badge = badge
        self.gradientColors = gradientColors
        self.tipShortcut = tipShortcut
    }
}

public struct FunnyMessagesProvider {
    public static let allGeneralMessages: [FunnyMessage] = [
        FunnyMessage(
            headline: "404: Clipboard Not Found",
            subtext: "Did you forget to press ⌘C? Don't worry, your secrets are safe with Sorta.",
            icon: "questionmark.folder.fill",
            badge: "Error 404",
            gradientColors: [Color.orange, Color.red]
        ),
        FunnyMessage(
            headline: "Nothing here... Sorta.",
            subtext: "A pristine void ready for your next StackOverflow copy-paste masterpiece.",
            icon: "sparkles",
            badge: "Blank Canvas",
            gradientColors: [Color.purple, Color.indigo]
        ),
        FunnyMessage(
            headline: "Ctrl+C... wait, this is a Mac: ⌘C!",
            subtext: "Muscle memory is tough. Tap Command-C to give your clipboard some purpose.",
            icon: "command",
            badge: "Mac Reflexes",
            gradientColors: [Color.blue, Color.cyan]
        ),
        FunnyMessage(
            headline: "Your clipboard is fasting today",
            subtext: "Feed it some delicious JSON, cURL snippets, hex colors, or screenshots.",
            icon: "fork.knife",
            badge: "Hungry Buffer",
            gradientColors: [Color.green, Color.teal]
        ),
        FunnyMessage(
            headline: "Zero items copied",
            subtext: "Somewhere out there, a hardcore developer is typing every single semicolon from scratch.",
            icon: "keyboard.fill",
            badge: "Legend Mode",
            gradientColors: [Color.pink, Color.purple]
        ),
        FunnyMessage(
            headline: "The void is staring back",
            subtext: "It whispers: 'Copy something, human. Even a random lorem ipsum will satisfy me.'",
            icon: "eye.fill",
            badge: "Existential Dev",
            gradientColors: [Color.indigo, Color.blue]
        ),
        FunnyMessage(
            headline: "A developer without ⌘C...",
            subtext: "...is just an overly caffeinated typist. Save your fingers and copy with pride!",
            icon: "cup.and.saucer.fill",
            badge: "Coffee First",
            gradientColors: [Color.orange, Color(red: 0.6, green: 0.35, blue: 0.15)]
        ),
        FunnyMessage(
            headline: "Suspiciously quiet in here...",
            subtext: "Did you just clear your history to hide evidence of your ChatGPT prompts? 🤫",
            icon: "shield.lefthalf.filled",
            badge: "Incognito Mode",
            gradientColors: [Color.teal, Color.blue]
        ),
        FunnyMessage(
            headline: "Clipboard buffer: 0 bytes",
            subtext: "RAM is cheap, but your clipboard is completely empty. Let's fill those bits.",
            icon: "memorychip.fill",
            badge: "0 Bytes Used",
            gradientColors: [Color.cyan, Color.teal]
        ),
        FunnyMessage(
            headline: "As empty as prod on Friday 5 PM",
            subtext: "No deployments, no broken builds, and zero clips in the buffer. Pure serenity.",
            icon: "moon.stars.fill",
            badge: "Friday Deploy",
            gradientColors: [Color.blue, Color.purple]
        ),
        FunnyMessage(
            headline: "Ready for your copy-pasta",
            subtext: "We promise never to tell your tech lead that 90% of the codebase was copied.",
            icon: "doc.on.doc.fill",
            badge: "Open Source Pro",
            gradientColors: [Color.yellow, Color.orange]
        ),
        FunnyMessage(
            headline: "It's dangerous to go alone! Take ⌘C.",
            subtext: "Equip your clipboard with text or images by pressing Command-C in any application.",
            icon: "gamecontroller.fill",
            badge: "Quest Ready",
            gradientColors: [Color.red, Color.pink]
        ),
        FunnyMessage(
            headline: "Tumbleweeds rolling by... 🌾",
            subtext: "The clipboard desert is silent. Copy a link or screenshot to summon life.",
            icon: "wind",
            badge: "Ghost Town",
            gradientColors: [Color.orange, Color.yellow]
        ),
        FunnyMessage(
            headline: "Waiting for your next stroke of genius",
            subtext: "Or that 400-line regex from StackOverflow that nobody on the team understands.",
            icon: "wand.and.stars",
            badge: "Regex Wizard",
            gradientColors: [Color.purple, Color.pink]
        ),
        FunnyMessage(
            headline: "Feed the beast!",
            subtext: "Sorta eats URLs, JSON, QR codes, hex colors, timestamps, and images for breakfast.",
            icon: "bolt.badge.clock.fill",
            badge: "Sorta Superpowers",
            gradientColors: [Color.cyan, Color.blue]
        ),
        FunnyMessage(
            headline: "Why did the developer cross the road?",
            subtext: "To copy code from the other repository. Press ⌘C to start your journey.",
            icon: "figure.walk",
            badge: "Dad Joke",
            gradientColors: [Color.green, Color.teal]
        ),
        FunnyMessage(
            headline: "git commit -m 'Initial empty state'",
            subtext: "Untracked clipboard items: 0. Stage some text with ⌘C and make history.",
            icon: "terminal.fill",
            badge: "Git Status",
            gradientColors: [Color.mint, Color.green]
        ),
        FunnyMessage(
            headline: "Clipboard level: Level 1 Novice",
            subtext: "Copy your first item to level up and unlock Sorta's dynamic transformers.",
            icon: "trophy.fill",
            badge: "XP: 0 / 100",
            gradientColors: [Color.yellow, Color.orange]
        )
    ]

    public static func categoryMessage(for category: ClipCategory) -> FunnyMessage {
        switch category {
        case .json:
            return FunnyMessage(
                headline: "No JSON found in history",
                subtext: "Not even a single `{ \"hello\": \"world\" }`. Copy some raw JSON to auto-prettify and typecheck!",
                icon: "curlybraces",
                badge: "JSON Inspector",
                gradientColors: [Color.yellow, Color.orange]
            )
        case .url:
            return FunnyMessage(
                headline: "Zero links copied yet",
                subtext: "Did the internet run out of URLs? Copy a tracking-heavy link to strip utm_ tags automatically!",
                icon: "link",
                badge: "URL Sanitizer",
                gradientColors: [Color.blue, Color.cyan]
            )
        case .image:
            return FunnyMessage(
                headline: "No screenshots or images",
                subtext: "Take a screenshot (⇧⌘4) or copy an image to test live OCR text & QR barcode scanning!",
                icon: "photo.fill",
                badge: "Vision OCR",
                gradientColors: [Color.purple, Color.pink]
            )
        case .color:
            return FunnyMessage(
                headline: "No colors copied yet",
                subtext: "Your clipboard is strictly monochrome. Copy a hex code like #FF5733 to inspect HSL, RGB, and Swift Color tokens!",
                icon: "paintpalette.fill",
                badge: "Color Studio",
                gradientColors: [Color.pink, Color.red]
            )
        case .jwt:
            return FunnyMessage(
                headline: "No JWT tokens found",
                subtext: "You are completely unauthorized! Copy a Bearer token to inspect header claims & expiry.",
                icon: "lock.shield.fill",
                badge: "JWT Inspector",
                gradientColors: [Color.red, Color.purple]
            )
        case .curl:
            return FunnyMessage(
                headline: "No cURL commands detected",
                subtext: "Copy a cURL request from browser DevTools to convert to Fetch, Python requests, or URLSession.",
                icon: "terminal.fill",
                badge: "API Transformer",
                gradientColors: [Color.teal, Color.blue]
            )
        case .timestamp:
            return FunnyMessage(
                headline: "No epoch timestamps found",
                subtext: "Time stands still. Copy an integer like 1700000000 to convert to human dates and ISO 8601!",
                icon: "clock.fill",
                badge: "Time Traveler",
                gradientColors: [Color.indigo, Color.cyan]
            )
        case .base64:
            return FunnyMessage(
                headline: "No Base64 strings detected",
                subtext: "Copy an encoded Base64 payload to decode raw text or inspect binary payloads instantly.",
                icon: "lock.rectangle.stack.fill",
                badge: "Base64 Decoder",
                gradientColors: [Color.green, Color.blue]
            )
        case .text:
            return FunnyMessage(
                headline: "No text clips in history",
                subtext: "Copy any text to remove invisible zero-width spaces, strip smart quotes, or transform casing.",
                icon: "doc.text.fill",
                badge: "Text Sanitizer",
                gradientColors: [Color.blue, Color.purple]
            )
        }
    }

    public static func searchMessage(for query: String) -> FunnyMessage {
        let options = [
            FunnyMessage(
                headline: "Searched the entire multiverse...",
                subtext: "Found zero clips matching \"\(query)\". Even AI couldn't hallucinate this one.",
                icon: "magnifyingglass",
                badge: "404 In History",
                gradientColors: [Color.orange, Color.pink],
                tipShortcut: "Clear Search"
            ),
            FunnyMessage(
                headline: "Ghost in the clipboard",
                subtext: "No results for \"\(query)\". Maybe that brilliant snippet was just a fever dream?",
                icon: "sparkle.magnifyingglass",
                badge: "Zero Results",
                gradientColors: [Color.purple, Color.blue],
                tipShortcut: "Clear Search"
            ),
            FunnyMessage(
                headline: "No clips in this timeline",
                subtext: "Couldn't find \"\(query)\". Check your spelling or tap 'Clear' to view all history.",
                icon: "binoculars.fill",
                badge: "Lost Clip",
                gradientColors: [Color.cyan, Color.teal],
                tipShortcut: "Clear Search"
            ),
            FunnyMessage(
                headline: "Mission Impossible",
                subtext: "We scanned every byte, but \"\(query)\" is nowhere to be found. Try fewer keywords.",
                icon: "eye.slash.fill",
                badge: "Top Secret",
                gradientColors: [Color.red, Color.orange],
                tipShortcut: "Clear Search"
            )
        ]
        return options.randomElement() ?? options[0]
    }

    public static func randomMessage() -> FunnyMessage {
        allGeneralMessages.randomElement() ?? allGeneralMessages[0]
    }
}
