import XCTest
@testable import Sorta

final class SortaTests: XCTestCase {

    func testURLCleanerTransformer() {
        let transformer = URLCleanerTransformer()
        let dirtyURL = "https://github.com/apple/swift?utm_source=twitter&utm_medium=social&si=12345"

        XCTAssertTrue(transformer.detect(content: dirtyURL))
        let options = transformer.transform(content: dirtyURL)

        XCTAssertFalse(options.isEmpty)
        let cleanOption = options.first(where: { $0.title == "Clean Tracking Parameters" })
        XCTAssertNotNil(cleanOption)
        XCTAssertEqual(cleanOption?.transformedContent, "https://github.com/apple/swift")
    }

    func testJSONTransformerPrettifyAndTypes() {
        let transformer = JSONTransformer()
        let rawJSON = "{\"user_id\":402,\"username\":\"hariom\",\"is_active\":true}"

        XCTAssertTrue(transformer.detect(content: rawJSON))
        let options = transformer.transform(content: rawJSON)

        XCTAssertGreaterThanOrEqual(options.count, 3)

        let tsOption = options.first(where: { $0.title == "Generate TypeScript Interface" })
        XCTAssertNotNil(tsOption)
        XCTAssertTrue(tsOption?.transformedContent.contains("username: string;") ?? false)

        let swiftOption = options.first(where: { $0.title == "Generate Swift Codable Struct" })
        XCTAssertNotNil(swiftOption)
        XCTAssertTrue(swiftOption?.transformedContent.contains("let user_id: Int") ?? false)
    }

    func testCURLTransformer() {
        let transformer = CURLTransformer()
        let curlCmd = "curl -X POST https://api.example.com/data -H 'Content-Type: application/json' -d '{\"key\":\"val\"}'"

        XCTAssertTrue(transformer.detect(content: curlCmd))
        let options = transformer.transform(content: curlCmd)

        XCTAssertEqual(options.count, 3)
        let fetchOption = options.first(where: { $0.title.contains("JavaScript fetch") })
        XCTAssertNotNil(fetchOption)
        XCTAssertTrue(fetchOption?.transformedContent.contains("fetch('https://api.example.com/data'") ?? false)
    }

    func testColorTransformer() {
        let transformer = ColorTransformer()
        let hexColor = "#FF5733"

        XCTAssertTrue(transformer.detect(content: hexColor))
        let options = transformer.transform(content: hexColor)

        XCTAssertFalse(options.isEmpty)
        let swiftUIOption = options.first(where: { $0.title.contains("SwiftUI Color") })
        XCTAssertNotNil(swiftUIOption)
        XCTAssertTrue(swiftUIOption?.transformedContent.contains("Color(red: 1.000, green: 0.341, blue: 0.200)") ?? false)
    }

    func testTimestampTransformer() {
        let transformer = TimestampTransformer()
        let timestamp = "1754034807"

        XCTAssertTrue(transformer.detect(content: timestamp))
        let options = transformer.transform(content: timestamp)

        XCTAssertFalse(options.isEmpty)
        let isoOption = options.first(where: { $0.title.contains("ISO-8601") })
        XCTAssertNotNil(isoOption)
        XCTAssertTrue(isoOption?.transformedContent.contains("2026-08-01") ?? false)
    }

    func testTextSanitizerTransformer() {
        let transformer = TextSanitizerTransformer()
        let dirtyText = "Hello\u{200B} “World”"

        XCTAssertTrue(transformer.detect(content: dirtyText))
        let options = transformer.transform(content: dirtyText)

        let sanitizedOption = options.first(where: { $0.title.contains("Sanitize") })
        XCTAssertNotNil(sanitizedOption)
        XCTAssertEqual(sanitizedOption?.transformedContent, "Hello \"World\"")
    }
}
