// swift-tools-version: 6.2
// The direct download, built by build.sh with `swift build`. The App Store build doesn't use this:
// it compiles a subset of Sources/ itself (AppStore/build.sh, AppStore/project.yml).
import PackageDescription

let package = Package(
    name: "WheresMyMouse",
    platforms: [.macOS(.v14)], // AmoreKit needs macOS 14
    dependencies: [
        .package(url: "https://github.com/AmoreComputer/AmoreKit", from: "0.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "WheresMyMouse",
            dependencies: [
                "Sparkle",
                .product(name: "AmoreLicensing", package: "AmoreKit"),
                .product(name: "AmoreCheckout", package: "AmoreKit"),
            ],
            path: "Sources",
            swiftSettings: [.swiftLanguageMode(.v5)],
            // Sparkle.framework is embedded in Contents/Frameworks.
            linkerSettings: [.unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])]
        ),
        // Downloaded and checksum-verified by build.sh: SwiftPM's own download of Sparkle's
        // binary hangs here, while the same file comes down fine with curl.
        .binaryTarget(name: "Sparkle", path: "build/Sparkle.xcframework"),
    ]
)
