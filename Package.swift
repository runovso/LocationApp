// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocationApp",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "LocationApp",
            targets: ["LocationApp"]),
    ],
    targets: [
        .target(
            name: "LocationApp"),
        .testTarget(
            name: "LocationAppTests",
            dependencies: ["LocationApp"]),
    ]
)
