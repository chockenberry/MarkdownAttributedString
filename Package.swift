// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownAttributedString",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_14),
    ],
    products: [
        .library(
            name: "MarkdownAttributedString",
            targets: ["MarkdownAttributedString"]),
    ],
    targets: [
        .target(
            name: "MarkdownAttributedString",
            dependencies: []),
        .testTarget(
            name: "MarkdownAttributedStringTests",
            dependencies: ["MarkdownAttributedString"]),
    ]
)
