// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sorta",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Sorta", targets: ["Sorta"])
    ],
    targets: [
        .executableTarget(
            name: "Sorta",
            path: "Sources/Sorta"
        ),
        .testTarget(
            name: "SortaTests",
            dependencies: ["Sorta"],
            path: "Tests/SortaTests"
        )
    ]
)
