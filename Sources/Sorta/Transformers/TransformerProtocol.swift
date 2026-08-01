import Foundation

public protocol TransformerProtocol {
    var category: ClipCategory { get }
    func detect(content: String) -> Bool
    func transform(content: String) -> [TransformOption]
}
