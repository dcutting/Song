// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Song",
    dependencies: [
        .package(url: "https://github.com/dcutting/Syft.git", from: "0.0.0")
    ],
    targets: [
        .target(
            name: "Sing",
            dependencies: ["Song"]),
        .target(
            name: "Song",
            dependencies: ["Syft"]),
        .testTarget(
            name: "SongTests",
            dependencies: ["Song"])
    ]
)
