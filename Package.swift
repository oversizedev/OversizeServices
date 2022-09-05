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
        .library(name: "OversizeHealthService", targets: ["OversizeHealthService"]),
        .library(name: "OversizeSecurityService", targets: ["OversizeSecurityService"]),
        .library(name: "OversizeServices", targets: ["OversizeServices"]),
        .library(name: "OversizeSettingsService", targets: ["OversizeSettingsService"]),
        .library(name: "OversizeStoreService", targets: ["OversizeStoreService"]),

    ],
    dependencies: [
        .package(name: "OversizeCore", path: "../OversizeCore"),
        .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
        .package(name: "OversizeResources", path: "../OversizeResources"),
    ],
    targets: [
        .target(
            name: "OversizeHealthService",
            dependencies: [
                "OversizeServices",
                // .product(name: "OversizeServices", package: "OversizeServices"),
            ]
        ),
        .target(
            name: "OversizeSecurityService",
            dependencies: [
                "OversizeServices",
                // .product(name: "OversizeServices", package: "OversizeServices"),
            ]
        ),
        .target(
            name: "OversizeServices",
            dependencies: [
                //                "OversizeLocalizable",
//                "OversizeResources"
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
        .target(
            name: "OversizeSettingsService",
            dependencies: [
                "OversizeServices",
                "OversizeSecurityService",
                // "OversizeCraft",
                // .product(name: "OversizeServices", package: "OversizeServices"),
                // .product(name: "OversizeSecurityService", package: "OversizeServices"),
                // "OversizeStore",
                // .product(name: "OversizeUI", package: "OversizeUI"),
            ]
        ),
        .target(
            name: "OversizeStoreService",
            dependencies: [
                "OversizeServices",
                "OversizeSettingsService",
                .product(name: "OversizeCore", package: "OversizeCore"),
            ]
        ),

        .testTarget(
            name: "OversizeServicesTests",
            dependencies: ["OversizeServices"]
        ),
    ]
)
