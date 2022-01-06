// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlexibleView",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "FlexibleView",
            targets: ["FlexibleView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlexibleView",
            dependencies: []),
        .testTarget(
            name: "FlexibleViewTests",
            dependencies: ["FlexibleView"]),
    ]
)
