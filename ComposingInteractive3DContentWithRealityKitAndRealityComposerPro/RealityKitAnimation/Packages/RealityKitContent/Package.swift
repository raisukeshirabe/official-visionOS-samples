// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The package manifest.
*/

import PackageDescription

let package = Package(
    name: "RealityKitContent",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "RealityKitContent",
            targets: ["RealityKitContent"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "RealityKitContent",
            dependencies: [])
    ]
)
