// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let productionDependencies: [PackageDescription.Package.Dependency] = { [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
] }()

let developmentDependencies: [PackageDescription.Package.Dependency] = { [
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
] }()

let package = Package(
    name: "OversizeServices",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "OversizeHealthService", targets: ["OversizeHealthService"]),
        .library(name: "OversizeCloudKitService", targets: ["OversizeCloudKitService"]),
        .library(name: "OversizeServices", targets: ["OversizeServices"]),
        .library(name: "OversizeStoreService", targets: ["OversizeStoreService"]),
        .library(name: "OversizeLocationService", targets: ["OversizeLocationService"]),
        .library(name: "OversizeCalendarService", targets: ["OversizeCalendarService"]),
        .library(name: "OversizeContactsService", targets: ["OversizeContactsService"]),
        .library(name: "OversizeNotificationService", targets: ["OversizeNotificationService"]),
        .library(name: "OversizeFileManagerService", targets: ["OversizeFileManagerService"]),
    ],
    dependencies: productionDependencies,
    targets: [
        .target(
            name: "OversizeServices",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeFileManagerService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeContactsService",
            dependencies: [
                "OversizeServices",
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeCalendarService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeHealthService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeLocationService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeCloudKitService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeStoreService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .target(
            name: "OversizeNotificationService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Factory", package: "Factory"),
            ]
        ),
        .testTarget(
            name: "OversizeServicesTests",
            dependencies: [
                "OversizeServices",
                .product(name: "Factory", package: "Factory"),
            ]
        ),
    ]
)
