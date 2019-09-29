// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MerchantKit",
    platforms: [.iOS(.v11), .macOS(.v10_14)],
    products: [
        .library(name: "MerchantKit", type: .static, targets: ["MerchantKit"])
    ],
    targets: [
        .target(name: "MerchantKit", dependencies: ["Helpers"], path: "Source"),
        .testTarget(name: "MerchantKitTests", dependencies: ["MerchantKit", "Helpers"], path: "Tests"),
        .target(name: "Helpers", path: "Helpers", publicHeadersPath: "")
    ]
)
