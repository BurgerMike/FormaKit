// swift-tools-version: 5.9
// This package defines a modular 2D/3D geometry library inspired by Formu3D.
// It splits functionality into separate targets for math, 2D shapes, 3D meshes,
// skeletal animation and simple physics.  Optional bridges to SceneKit, Metal
// and CoreGraphics are provided via conditional compilation.  See README for
// usage examples.

import PackageDescription

let package = Package(
    name: "FormaKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(name: "FormaKit2D", targets: ["FormaKit2D"]),
        .library(name: "FormaKit3D", targets: ["FormaKit3D"]),
        .library(name: "FormaKitSkeleton", targets: ["FormaKitSkeleton"]),
        .library(name: "FormaKitPhysics", targets: ["FormaKitPhysics"]),
        .library(name: "FormaKitSceneKitBridge", targets: ["FormaKitSceneKitBridge"]),
        .library(name: "FormaKitMetalBridge", targets: ["FormaKitMetalBridge"]),
        .library(name: "FormaKitCoreGraphicsBridge", targets: ["FormaKitCoreGraphicsBridge"]),
    ],
    targets: [
        // Core 2D geometry definitions and shapes
        .target(
            name: "FormaKit2D",
            dependencies: []
        ),
        // Core 3D geometry definitions and mesh utilities.  Depends on 2D for
        // extruding shapes into 3D.
        .target(
            name: "FormaKit3D",
            dependencies: ["FormaKit2D"]
        ),
        // Skeletal animation data structures and simple linear blend skinning.
        .target(
            name: "FormaKitSkeleton",
            dependencies: ["FormaKit3D"]
        ),
        // Basic rigid body physics utilities.  Depends on 3D.
        .target(
            name: "FormaKitPhysics",
            dependencies: ["FormaKit3D"]
        ),
        // SceneKit bridge: convert meshes and skinned meshes into SCNGeometry and
        // SCNSkinner structures.  Only compiled on platforms with SceneKit.
        .target(
            name: "FormaKitSceneKitBridge",
            dependencies: ["FormaKit3D", "FormaKitSkeleton"],
            swiftSettings: [
                .define("ENABLE_SCENEKIT", .when(platforms: [.iOS, .macOS]))
            ]
        ),
        // Metal bridge: convert meshes into MTLBuffer objects.  Only compiled
        // when Metal is available.
        .target(
            name: "FormaKitMetalBridge",
            dependencies: ["FormaKit3D"],
            swiftSettings: [
                .define("ENABLE_METAL", .when(platforms: [.iOS, .macOS]))
            ]
        ),
        // CoreGraphics bridge: convert 2D shapes into CGPath for drawing with
        // Core Graphics or SwiftUI.  Only compiled when CoreGraphics is available.
        .target(
            name: "FormaKitCoreGraphicsBridge",
            dependencies: ["FormaKit2D"],
            swiftSettings: [
                .define("ENABLE_COREGRAPHICS", .when(platforms: [.iOS, .macOS]))
            ]
        ),
        // Unit tests verifying that basic types and extrusions work correctly.
        .testTarget(
            name: "FormaKitTests",
            dependencies: ["FormaKit2D", "FormaKit3D", "FormaKitSkeleton", "FormaKitPhysics"]
        ),
    ]
)