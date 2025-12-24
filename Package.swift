// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MouseRemapper",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "mouse-remapper",
            targets: ["MouseRemapper"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MouseRemapper",
            dependencies: []
        ),
        .testTarget(
            name: "MouseRemapperTests",
            dependencies: ["MouseRemapper"]
        )
    ]
)
