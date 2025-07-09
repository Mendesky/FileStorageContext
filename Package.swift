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
                "BusinessClientAggregate",
                "GoogleCloudStorage"
            ]
        ),
        .executable(
            name: "FileStorageContextServer",
            targets: ["FileStorageContextServer"]),
    ],
    dependencies: [
        .package(url: "git@github.com:Mendesky/DDDKit.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-hummingbird.git", from: "2.0.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.14.0"),
        .package(url: "https://github.com/vapor-community/google-cloud-kit.git", from: "1.0.0-alpha.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BusinessClientAggregate",
            dependencies: [
                .product(name: "DDDKit", package: "DDDKit"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "GoogleCloudKit", package: "google-cloud-kit")
            ],
            resources: [
                .process("openapi-generator-config.yml"),
                .process("openapi.yml"),
                .process("event-generator-config.yaml"),
                .process("event.yaml"),
                .process("projection-model.yaml")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
                .plugin(name: "DomainEventGeneratorPlugin", package: "DDDKit"),
                .plugin(name: "ProjectionModelGeneratorPlugin", package: "DDDKit")
            ]
        ),
        .target(
            name: "GoogleCloudStorage",
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
        .target(
            name: "SharedTestUtility",
            dependencies: [
                "BusinessClientAggregate",
                .product(name: "TestUtility", package: "DDDKit")
            ],
            path: "Tests/SharedTestUtility"
        ),
        .testTarget(
            name: "BusinessClientTests",
            dependencies: [
                "SharedTestUtility"
            ]
        ),
        .executableTarget(
            name: "FileStorageContextServer",
            dependencies: [
                "GoogleCloudStorage",
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "Hummingbird", package: "hummingbird")
            ]
        )
    ]
)
