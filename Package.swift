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
        .package(url: "https://github.com/ra1028/Carbon.git", from: "1.0.0-rc.6")
    ],
    targets: [
        .target(
            name: "CellsReloadable",
            dependencies: [
                "Carbon"
            ]
        )
    ]
)
