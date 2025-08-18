// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileStorageContext",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FileStorageContext",
            targets: [
                "GoogleCloudStorage",
                "FileStorageCore"
            ]
        ),
        .executable(
            name: "FileStorageContextServer",
            targets: ["FileStorageContextServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.3.0"),
        .package(url: "https://github.com/Mendesky/google-cloud-kit.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FileStorageCore"
        ),
        .target(
            name: "GoogleCloudStorage",
            dependencies: [
                "FileStorageCore",
                .product(name: "GoogleCloudKit", package: "google-cloud-kit"),
            ]
        ),
        .executableTarget(
            name: "FileStorageContextServer",
            dependencies: [
                "GoogleCloudStorage"
            ]
        ),
        .testTarget(
            name: "GoogleCloudStorageTests",
            dependencies: [
                "GoogleCloudStorage"
            ]
        ),
    ],
    swiftLanguageModes: [
        .v5
    ]
)
