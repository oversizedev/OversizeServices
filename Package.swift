// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let remoteDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(name: "OversizeModels", path: "../OversizeModels"),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
]

let dependencies: [PackageDescription.Package.Dependency] = remoteDependencies

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
        .library(name: "OversizeServices", targets: ["OversizeServices"]),
        .library(name: "OversizeStoreService", targets: ["OversizeStoreService"]),
        .library(name: "OversizeLocationService", targets: ["OversizeLocationService"]),
        .library(name: "OversizeCalendarService", targets: ["OversizeCalendarService"]),
        .library(name: "OversizeContactsService", targets: ["OversizeContactsService"]),
        .library(name: "OversizeNotificationService", targets: ["OversizeNotificationService"]),
        .library(name: "OversizeFileManagerService", targets: ["OversizeFileManagerService"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeServices",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeFileManagerService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeContactsService",
            dependencies: [
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeCalendarService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeHealthService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeLocationService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeStoreService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeNotificationService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeServicesTests",
            dependencies: [
                "OversizeServices",
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
    ],
)
