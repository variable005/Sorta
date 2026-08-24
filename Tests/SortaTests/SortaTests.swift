import Foundation
@testable import Sorta

// Basic test harness verifying transformer behaviors
public struct SortaTestSuite {
    public static func runAllTests() -> Bool {
        var passed = 0
        var failed = 0

        func assert(_ condition: Bool, _ message: String) {
            if condition {
                passed += 1
            } else {
                failed += 1
                print("❌ FAIL: \(message)")
            }
        }

        // 1. LineSorter Test
        let sorter = LineSorterTransformer()
        let text = "item10\nitem2\nitem1\nitem2\nitem3"
        assert(sorter.detect(content: text), "LineSorter should detect multiline text")
        let sortOpts = sorter.transform(content: text)
        let azOpt = sortOpts.first(where: { $0.title.contains("A-Z Natural") })
        assert(azOpt?.transformedContent == "item1\nitem2\nitem2\nitem3\nitem10", "Natural sort order")

        // 2. URLCleaner Test
        let urlCleaner = URLCleanerTransformer()
        let dirtyURL = "https://github.com/apple/swift?z_param=1&utm_source=twitter&a_param=2&si=12345"
        assert(urlCleaner.detect(content: dirtyURL), "URLCleaner detects valid HTTP URL")
        let urlOpts = urlCleaner.transform(content: dirtyURL)
        let cleanOpt = urlOpts.first(where: { $0.title == "Clean Tracking Parameters" })
        assert(cleanOpt?.transformedContent == "https://github.com/apple/swift?a_param=2&z_param=1", "Strip tracking params")

        // 3. JSON Test
        let jsonTrans = JSONTransformer()
        let rawJSON = "{\"user_id\":402,\"username\":\"hariom\",\"is_active\":true}"
        assert(jsonTrans.detect(content: rawJSON), "JSON detected")
        let jsonOpts = jsonTrans.transform(content: rawJSON)
        assert(jsonOpts.contains(where: { $0.title == "Prettify JSON" }), "Prettify option exists")
        assert(jsonOpts.contains(where: { $0.title == "TypeScript Interface" }), "TypeScript option exists")
        assert(jsonOpts.contains(where: { $0.title == "Swift Codable Struct" }), "Swift Codable option exists")

        // 4. CURL Test
        let curlTrans = CURLTransformer()
        let curlCmd = "curl -X POST 'https://api.example.com/data' -H 'Authorization: Bearer xyz' -H 'Accept: application/json' -d '{\"key\":\"val\"}'"
        assert(curlTrans.detect(content: curlCmd), "CURL detected")
        let curlOpts = curlTrans.transform(content: curlCmd)
        assert(curlOpts.count == 3, "3 cURL transformation targets (fetch, python, swift)")

        // 5. Base64 Test
        let b64Trans = Base64Transformer()
        let encoded = "SGVsbG8gV29ybGQ="
        assert(b64Trans.detect(content: encoded), "Base64 detected")
        let b64Opts = b64Trans.transform(content: encoded)
        assert(b64Opts.first?.transformedContent == "Hello World", "Decoded base64")

        // 6. Timestamp Test
        let timeTrans = TimestampTransformer()
        assert(timeTrans.detect(content: "1700000000"), "Epoch timestamp detected")

        // 7. Color Test
        let colorTrans = ColorTransformer()
        assert(colorTrans.detect(content: "#FF5733"), "Hex color detected")

        print("SortaTestSuite complete: \(passed) passed, \(failed) failed.")
        return failed == 0
    }
}
