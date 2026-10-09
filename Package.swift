// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Penny",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Pure-Swift domain: budgets, bills, net worth, household split and the sample ledger.
        .library(name: "PennyCore", targets: ["PennyCore"]),
        // Server-rendered product site and web dashboard, built from PennyCore.
        .library(name: "PennyWeb", targets: ["PennyWeb"]),
        // Typed client for the JSON API.
        .library(name: "PennyClient", targets: ["PennyClient"]),
        // SwiftUI screens for the iPhone app (compiles to an empty module where SwiftUI is unavailable).
        .library(name: "PennyUI", targets: ["PennyUI"]),
        // HTTP service: the site, the JSON API and static assets.
        .executable(name: "penny-server", targets: ["PennyServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.20.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.30.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.30.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0"),
    ],
    targets: [
        .target(name: "PennyCore"),
        .target(
            name: "PennyWeb",
            dependencies: ["PennyCore"]
        ),
        .target(
            name: "PennyClient",
            dependencies: ["PennyCore"]
        ),
        .target(
            name: "PennyUI",
            dependencies: ["PennyCore", "PennyClient"]
        ),
        .target(
            name: "PennyServerKit",
            dependencies: [
                "PennyCore",
                "PennyWeb",
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ]
        ),
        .executableTarget(
            name: "PennyServer",
            dependencies: ["PennyServerKit"]
        ),
        .testTarget(name: "PennyCoreTests", dependencies: ["PennyCore"]),
        .testTarget(name: "PennyWebTests", dependencies: ["PennyWeb", "PennyCore"]),
        .testTarget(name: "PennyClientTests", dependencies: ["PennyClient", "PennyCore"]),
        .testTarget(
            name: "PennyServerTests",
            dependencies: [
                "PennyServerKit",
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ]
        ),
    ]
)
