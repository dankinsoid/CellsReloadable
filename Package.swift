// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CellsReloadable",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "CellsReloadable", targets: ["CellsReloadable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ra1028/DifferenceKit.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "CellsReloadable",
            dependencies: ["DifferenceKit"]
        )
    ]
)
