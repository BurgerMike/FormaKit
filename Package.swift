// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FormaKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v15)
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
    dependencies: [],
    targets: [
        .target(name: "FormaKit2D", dependencies: []),
        .target(name: "FormaKit3D", dependencies: []),
        .target(name: "FormaKitPhysics", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitSkeleton", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitMetalBridge", dependencies: ["FormaKit3D"]),
        .target(name: "FormaKitSceneKitBridge", dependencies: ["FormaKit3D"]),
        .target(
            name: "FormaKitCoreGraphicsBridge",
            dependencies: ["FormaKit2D"],
            swiftSettings: [
                .define("ENABLE_COREGRAPHICS", .when(platforms: [.iOS, .macOS]))
            ]
        ),
        .testTarget(
            name: "FormaKitTests",
            dependencies: ["FormaKit2D","FormaKit3D","FormaKitSkeleton","FormaKitPhysics"]
        ),
    ]
)

