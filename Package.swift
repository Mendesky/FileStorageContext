// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileStorageContext",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FileStorageContext",
            targets: ["FileUploader"]),
        .executable(
            name: "FileStorageContextServer",
            targets: ["FileStorageContextServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-hummingbird", from: "1.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.10.1"),
        .package(url: "https://github.com/vapor-community/google-cloud-kit.git", from: "1.0.0-alpha.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FileUploader",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "GoogleCloudKit", package: "google-cloud-kit")
            ],
            resources: [.process("openapi-generator-config.yml"),
                        .process("openapi.yml")],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .executableTarget(
            name: "FileStorageContextServer",
            dependencies: [
                "FileUploader",
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ]
        ),
        .testTarget(
            name: "FileStorageContextTests",
            dependencies: ["FileUploader"]),
    ]
)
