// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Song",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "song", targets: ["Sing"]),
        .library(name: "SongLang", targets: ["SongLang"])
    ],
    dependencies: [
        .package(url: "https://github.com/dcutting/Syft.git", exact: .init(0, 3, 0)),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/andybest/linenoise-swift.git", exact: .init(0, 0, 3)),
    ],
    targets: [
        .executableTarget(
            name: "Sing",
            dependencies: [
                "SongLang",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "LineNoise", package: "linenoise-swift")
            ]
        ),
        .target(
            name: "SongLang",
            dependencies: ["Syft"]),
        .testTarget(
            name: "SongTests",
            dependencies: ["SongLang"]),
        .testTarget(
            name: "SongPerformanceTests",
            dependencies: ["SongLang"])
    ]
)
