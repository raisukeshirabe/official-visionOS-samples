// swift-tools-version: 6.0
/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A package that contains model assets.
*/
import PackageDescription

let package = Package(
    name: "SwiftSplashTrackPieces",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SwiftSplashTrackPieces",
            targets: ["SwiftSplashTrackPieces"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftSplashTrackPieces",
            dependencies: []
        )
    ]
)
