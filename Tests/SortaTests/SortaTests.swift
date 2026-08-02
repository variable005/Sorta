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
    }

    func testCURLTransformer() {
        let transformer = CURLTransformer()
        let curlCmd = "curl -X POST https://api.example.com/data -H 'Content-Type: application/json' -d '{\"key\":\"val\"}'"

        XCTAssertTrue(transformer.detect(content: curlCmd))
        let options = transformer.transform(content: curlCmd)

        XCTAssertEqual(options.count, 3)
        let fetchOption = options.first(where: { $0.title.contains("JavaScript fetch") })
        XCTAssertNotNil(fetchOption)
    }

    func testBase64Transformer() {
        let transformer = Base64Transformer()
        let encoded = "SGVsbG8gV29ybGQ="

        XCTAssertTrue(transformer.detect(content: encoded))
        let options = transformer.transform(content: encoded)

        let decodeOption = options.first(where: { $0.title.contains("Decode Base64") })
        XCTAssertNotNil(decodeOption)
        XCTAssertEqual(decodeOption?.transformedContent, "Hello World")
    }

    func testHTMLEntityTransformer() {
        let transformer = HTMLEntityTransformer()
        let htmlStr = "&lt;div class=&quot;box&quot;&gt;Hello &amp; Welcome&lt;/div&gt;"

        XCTAssertTrue(transformer.detect(content: htmlStr))
        let options = transformer.transform(content: htmlStr)

        let decodeOption = options.first(where: { $0.title.contains("Decode HTML") })
        XCTAssertNotNil(decodeOption)
        XCTAssertEqual(decodeOption?.transformedContent, "<div class=\"box\">Hello & Welcome</div>")
    }

    func testMarkdownTableTransformer() {
        let transformer = MarkdownTableTransformer()
        let csvData = "Name,Age,Role\nHariom,25,Developer\nAlice,30,Designer"

        XCTAssertTrue(transformer.detect(content: csvData))
        let options = transformer.transform(content: csvData)

        XCTAssertFalse(options.isEmpty)
        XCTAssertTrue(options[0].transformedContent.contains("| Name | Age | Role |"))
        XCTAssertTrue(options[0].transformedContent.contains("| --- | --- | --- |"))
    }

    func testSQLTransformer() {
        let transformer = SQLTransformer()
        let sql = "select id, username from users where is_active = 1 order by id desc"

        XCTAssertTrue(transformer.detect(content: sql))
        let options = transformer.transform(content: sql)

        XCTAssertFalse(options.isEmpty)
        XCTAssertTrue(options[0].transformedContent.contains("SELECT"))
        XCTAssertTrue(options[0].transformedContent.contains("FROM users"))
        XCTAssertTrue(options[0].transformedContent.contains("WHERE"))
    }

    func testRegexEscaperTransformer() {
        let transformer = RegexEscaperTransformer()
        let regex = "/\\d{3}-\\w+/g"

        XCTAssertTrue(transformer.detect(content: regex))
        let options = transformer.transform(content: regex)

        let rawOption = options.first(where: { $0.title.contains("Swift Raw") })
        XCTAssertNotNil(rawOption)
        XCTAssertEqual(rawOption?.transformedContent, "#\"/\\d{3}-\\w+/g\"#")
    }

    @MainActor
    func testQueueManagerStack() {
        let queue = QueueManager.shared
        queue.clearQueue()
        queue.toggleQueueMode() // Enable

        queue.pushItem("Item1")
        queue.pushItem("Item2")

        XCTAssertEqual(queue.queueStack.count, 2)
        XCTAssertEqual(queue.queueStack.first, "Item1")

        queue.clearQueue()
        queue.toggleQueueMode() // Disable
    }

    @MainActor
    func testPrivacyGuardSensitiveKeyDetection() {
        let guardInst = PrivacyGuard.shared
        let awsKey = "AKIAIOSFODNN7EXAMPLE"
        let normalText = "Hello World"

        XCTAssertTrue(guardInst.isSensitiveContent(awsKey))
        XCTAssertFalse(guardInst.isSensitiveContent(normalText))

        let masked = guardInst.maskSensitiveContent(awsKey)
        XCTAssertTrue(masked.hasPrefix("AKIA"))
        XCTAssertTrue(masked.contains("****************"))
    }
}
