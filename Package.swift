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
    ],
    targets: [
        .target(name: "PennyCore"),
        .target(
            name: "PennyWeb",
            dependencies: ["PennyCore"]
        ),
        .testTarget(name: "PennyCoreTests", dependencies: ["PennyCore"]),
        .testTarget(name: "PennyWebTests", dependencies: ["PennyWeb", "PennyCore"]),
    ]
)
