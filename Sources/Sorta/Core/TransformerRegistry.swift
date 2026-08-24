import Foundation

public final class TransformerRegistry {
    public static let shared = TransformerRegistry()

    private let transformers: [TransformerProtocol]

    public init(transformers: [TransformerProtocol] = [
        JSONTransformer(),
        CURLTransformer(),
        URLCleanerTransformer(),
        JWTTransformer(),
        TimestampTransformer(),
        ColorTransformer(),
        Base64Transformer(),
        TextSanitizerTransformer()
    ]) {
        self.transformers = transformers
    }

    public func inspect(content: String) -> (category: ClipCategory, options: [TransformOption]) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (.text, [])
        }

        for transformer in transformers {
            if transformer.detect(content: trimmed) {
                let options = transformer.transform(content: trimmed)
                if !options.isEmpty {
                    return (transformer.category, options)
                }
            }
        }

        let defaultTransformer = TextSanitizerTransformer()
        return (.text, defaultTransformer.transform(content: trimmed))
    }
}
