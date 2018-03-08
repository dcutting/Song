// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Song",
    products: [
        .executable(name: "song", targets: ["Sing"]),
        .library(name: "Song", targets: ["Song"])
    ],
    dependencies: [
        .package(url: "https://github.com/dcutting/Syft.git", .branch("develop")),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
        .package(url: "https://github.com/dcutting/linenoise-swift.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Sing",
            dependencies: ["Song", "Utility", "LineNoise"]),
        .target(
            name: "Song",
            dependencies: ["Syft", "Utility"]),
        .testTarget(
            name: "SongTests",
            dependencies: ["Song"])
    ]
)
