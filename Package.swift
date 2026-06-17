// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "ISkeleton",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "Skeleton-Core", targets: ["SkeletonCore"]),
        .library(name: "Skeleton-SwiftUI", targets: ["SkeletonSwiftUI"]),
        .library(name: "Skeleton-UIKit", targets: ["SkeletonUIKit"]),
    ],
    targets: [
        .target(name: "SkeletonCore"),
        .target(name: "SkeletonSwiftUI", dependencies: ["SkeletonCore"]),
        .target(name: "SkeletonUIKit", dependencies: ["SkeletonCore"]),
        .testTarget(name: "SkeletonCoreTests", dependencies: ["SkeletonCore"]),
        .testTarget(name: "SkeletonUIKitTests", dependencies: ["SkeletonUIKit"]),
        .testTarget(name: "SkeletonSwiftUITests", dependencies: ["SkeletonSwiftUI"]),
    ]
)
