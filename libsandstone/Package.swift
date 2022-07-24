// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sandstone",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "Sandstone",
            targets: ["Sandstone"]),
    ],
    targets: [
        .target(
            name: "Sandstone",
            dependencies: [
                "CSandbox"
            ]
        ),
        .systemLibrary(name: "CSandbox")
    ]
)
