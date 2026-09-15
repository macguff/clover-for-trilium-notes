// swift-tools-version: 5.9
import PackageDescription

// CloverEditor — rich-text editing for Trilium notes. Vendored from Trinote (MPL-2.0); see NOTICE.md.
let package = Package(
    name: "CloverEditor",
    platforms: [.iOS(.v17)],
    products: [.library(name: "CloverEditor", targets: ["CloverEditor"])],
    targets: [
        .target(
            name: "CloverEditor",
            path: "Sources/CloverEditor",
            resources: [.copy("Resources/EditorWeb")],
            swiftSettings: [.define("CLOVER_EDITOR"), .enableExperimentalFeature("StrictConcurrency")]   // step toward Swift 6 (#16)
        ),
    ],
    swiftLanguageVersions: [.v5]
)
