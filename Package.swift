// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let productionDependencies: [PackageDescription.Package.Dependency] = { [
    .package(url: "http://github.com/oversizedev/OversizeCore.git", branch: "main"),
    .package(url: "http://github.com/oversizedev/OversizeLocalizable.git", branch: "main"),
    .package(url: "http://github.com/oversizedev/OversizeResources.git", branch: "main"),
]}()

let developmentDependencies: [PackageDescription.Package.Dependency] = { [
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeResources", path: "../OversizeResources"),
]}()

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
    dependencies: productionDependencies,
    targets: [
        .target(
            name: "OversizeServices",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
        .target(
            name: "OversizeHealthService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                // .product(name: "OversizeServices", package: "OversizeServices"),
            ]
        ),
        .target(
            name: "OversizeSecurityService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                // .product(name: "OversizeServices", package: "OversizeServices"),
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
