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
    ],
    targets: [
        .target(
            name: "Sing",
            dependencies: ["Song", "Utility"]),
        .target(
            name: "Song",
            dependencies: ["Syft"]),
        .testTarget(
            name: "SongTests",
            dependencies: ["Song"])
    ]
)
