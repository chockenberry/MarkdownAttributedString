// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MarkdownAttributedString",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "MarkdownAttributedString",
            targets: ["MarkdownAttributedString"]
        ),
    ],
    targets: [
        .target(
            name: "MarkdownAttributedString",
            path: "Sources",
            publicHeadersPath: "."
        ),
    ],
    swiftLanguageVersions: [.v5]
)
