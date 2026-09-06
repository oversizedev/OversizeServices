// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let remoteDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
]

let localDependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
]

let isLocalDev = FileManager.default.fileExists(atPath: "\(NSHomeDirectory())/Developer/Packages/OversizeCore")
let dependencies: [PackageDescription.Package.Dependency] = isLocalDev ? localDependencies : remoteDependencies

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
        .library(name: "OversizeServices", targets: ["OversizeServices"]),
        .library(name: "OversizeCloudService", targets: ["OversizeCloudService"]),
        .library(name: "OversizeHealthService", targets: ["OversizeHealthService"]),
        .library(name: "OversizeStoreService", targets: ["OversizeStoreService"]),
        .library(name: "OversizeLocationService", targets: ["OversizeLocationService"]),
        .library(name: "OversizeCalendarService", targets: ["OversizeCalendarService"]),
        .library(name: "OversizeContactsService", targets: ["OversizeContactsService"]),
        .library(name: "OversizeNotificationService", targets: ["OversizeNotificationService"]),
        .library(name: "OversizeFileManagerService", targets: ["OversizeFileManagerService"]),
        .library(name: "OversizeWebService", targets: ["OversizeWebService"]),
        .library(name: "OversizeWeatherService", targets: ["OversizeWeatherService"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeServices",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeCloudService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeFileManagerService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeContactsService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeCalendarService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeHealthService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeLocationService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeStoreService",
            dependencies: [
                "OversizeServices",
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeNotificationService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeWebService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
        ),
        .target(
            name: "OversizeWeatherService",
            dependencies: [
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            linkerSettings: [
                .linkedFramework("WeatherKit", .when(platforms: [.iOS, .macOS, .watchOS, .tvOS])),
            ],
        ),
        .testTarget(
            name: "OversizeServicesTests",
            dependencies: [
                "OversizeServices",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeCloudServiceTests",
            dependencies: [
                "OversizeCloudService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeCalendarServiceTests",
            dependencies: [
                "OversizeCalendarService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeContactsServiceTests",
            dependencies: [
                "OversizeContactsService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeFileManagerServiceTests",
            dependencies: [
                "OversizeFileManagerService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeHealthServiceTests",
            dependencies: [
                "OversizeHealthService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeLocationServiceTests",
            dependencies: [
                "OversizeLocationService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeNotificationServiceTests",
            dependencies: [
                "OversizeNotificationService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeStoreServiceTests",
            dependencies: [
                "OversizeStoreService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeWeatherServiceTests",
            dependencies: [
                "OversizeWeatherService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
        .testTarget(
            name: "OversizeWebServiceTests",
            dependencies: [
                "OversizeWebService",
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "FactoryTesting", package: "Factory"),
            ],
        ),
    ],
)
