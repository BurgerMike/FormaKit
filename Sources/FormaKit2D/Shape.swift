//  FormaKit
//  Shape.swift

import Foundation

/// A generic protocol describing a 2D shape. Shapes provide an ordered list
/// of vertices forming a closed loop (CCW winding).
public protocol Shape {
    associatedtype Scalar: BinaryFloatingPoint
    var vertices: [Vector2<Scalar>] { get }
}

/// A rectangle centered at the origin.
public struct Rectangle<T: BinaryFloatingPoint>: Shape {
    public typealias Scalar = T
    public var size: Vector2<T>
    @inlinable public init(width: T, height: T) {
        self.size = Vector2(width, height)
    }
    @inlinable public var vertices: [Vector2<T>] {
        let hw = size.x / 2
        let hh = size.y / 2
        return [
            Vector2(-hw, -hh),
            Vector2(hw, -hh),
            Vector2(hw,  hh),
            Vector2(-hw,  hh)
        ]
    }
}

/// A circle approximated by a regular polygon.
public struct Circle<T: BinaryFloatingPoint>: Shape {
    public typealias Scalar = T
    public var radius: T
    public var segments: Int
    @inlinable public init(radius: T, segments: Int = 32) {
        precondition(segments >= 3, "Circle needs at least 3 segments.")
        self.radius = radius
        self.segments = segments
    }
    @inlinable public var vertices: [Vector2<T>] {
        let n = segments
        let r = radius
        return (0..<n).map { i in
            let angle = T(i) * (2 * .pi) / T(n)
            return Vector2(r * T(cos(Double(angle))), r * T(sin(Double(angle))))
        }
    }
}

/// A polygon defined by an arbitrary list of points (CCW, non self-intersecting).
public struct Polygon<T: BinaryFloatingPoint>: Shape {
    public typealias Scalar = T
    public var points: [Vector2<T>]
    @inlinable public init(points: [Vector2<T>]) {
        precondition(points.count >= 3, "A polygon requires at least three points.")
        self.points = points
    }
    @inlinable public var vertices: [Vector2<T>] { points }
}

// Swift 6: conformidades Sendable condicionales para los concretos.
extension Rectangle: Sendable where T: Sendable {}
extension Circle: Sendable where T: Sendable {}
extension Polygon: Sendable where T: Sendable {}

