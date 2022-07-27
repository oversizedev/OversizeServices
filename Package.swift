// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OversizeServices",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "OversizeServices",
            targets: ["OversizeServices"]),
        .library(
            name: "OversizeHealthService",
            targets: ["OversizeHealthService"]),
    ],
    dependencies: [
        .package(name: "OversizeModels", path: "../OversizeModels"),
    ],
    targets: [
        .target(
            name: "OversizeServices",
            dependencies: []),
        .target(
            name: "OversizeHealthService",
            dependencies: [
                "OversizeServices",
                "OversizeModels"
            ]),
        .testTarget(
            name: "OversizeServicesTests",
            dependencies: ["OversizeServices"]),
    ]
)
