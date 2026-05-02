// swift-tools-version: 5.10
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
    dependencies: [
        // Required under Command-Line-Tools toolchain: ships the public `Testing`
        // module but not `_TestingInternals`, which SwiftPM's test runner needs.
        // Drop this once full Xcode is the build environment.
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.10.0")
    ],
    targets: [
        .executableTarget(
            name: "MouseRemapper",
            dependencies: []
        ),
        .testTarget(
            name: "MouseRemapperTests",
            dependencies: [
                "MouseRemapper",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ]
)
