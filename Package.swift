// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FormaKit",
    platforms: [
        .macOS(.v14), .iOS(.v16)
    ],
    products: [
        .library(name: "FormaKit2D", targets: ["FormaKit2D"]),
        .library(name: "FormaKit3D", targets: ["FormaKit3D"]),
        .library(name: "FormaKitPhysics", targets: ["FormaKitPhysics"]),
        .library(name: "FormaKitSkeleton", targets: ["FormaKitSkeleton"]),
        .library(name: "FormaKitMetalBridge", targets: ["FormaKitMetalBridge"]),
        .library(name: "FormaKitSceneKitBridge", targets: ["FormaKitSceneKitBridge"]),
        .library(name: "FormaKitCoreGraphicsBridge", targets: ["FormaKitCoreGraphicsBridge"]),
    ],
    targets: [
        .target(name: "FormaKit2D",
                swiftSettings: [
                    .enableUpcomingFeature("StrictConcurrency"),
                    .enableUpcomingFeature("InferSendableFromCaptures"),
                    .enableUpcomingFeature("DisableOutwardActorInference"),
                ]),
        .target(name: "FormaKit3D",
                swiftSettings: [
                    .enableUpcomingFeature("StrictConcurrency"),
                    .enableUpcomingFeature("InferSendableFromCaptures"),
                    .enableUpcomingFeature("DisableOutwardActorInference"),
                ]),
        .target(name: "FormaKitPhysics", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitSkeleton", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitMetalBridge", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitSceneKitBridge", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitCoreGraphicsBridge", dependencies: ["FormaKit2D"]),
        .testTarget(name: "FormaKitTests", dependencies: ["FormaKit2D","FormaKit3D"]),
    ]
)

