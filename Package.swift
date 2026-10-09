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
    ],
    targets: [
        .target(name: "PennyCore"),
        .testTarget(name: "PennyCoreTests", dependencies: ["PennyCore"]),
    ]
)
