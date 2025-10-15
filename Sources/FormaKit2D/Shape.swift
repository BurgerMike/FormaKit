//  FormaKit
//  Shape.swift
//
//  Defines basic 2D shape primitives.  Shapes are described by a sequence
//  of vertices in counter‑clockwise order.  They can be used for drawing
//  in 2D or extruded into 3D meshes via FormaKit3D.

import Foundation

/// A generic protocol describing a 2D shape.  Shapes provide an ordered list
/// of vertices forming a closed loop.  The convention is counter‑clockwise
/// (CCW) winding, which results in outward facing normals when extruded.
public protocol Shape {
    associatedtype Scalar: BinaryFloatingPoint
    /// The vertices that outline the shape.  The final segment connects the
    /// last vertex back to the first.
    var vertices: [Vector2<Scalar>] { get }
}

/// A rectangle centered at the origin.  The rectangle is defined by its
/// width and height.  The vertices are in CCW order starting at (-w/2, -h/2).
public struct Rectangle<T: BinaryFloatingPoint>: Shape {
    public typealias Scalar = T
    public var size: Vector2<T>
    public init(width: T, height: T) {
        self.size = Vector2(width, height)
    }
    public var vertices: [Vector2<T>] {
        let hw = size.x / 2
        let hh = size.y / 2
        return [
            Vector2(-hw, -hh),
            Vector2(hw, -hh),
            Vector2(hw, hh),
            Vector2(-hw, hh)
        ]
    }
}

/// A circle approximated by a regular polygon with a configurable number
/// of segments.  The circle is centered at the origin.
public struct Circle<T: BinaryFloatingPoint>: Shape {
    public typealias Scalar = T
    public var radius: T
    public var segments: Int
    public init(radius: T, segments: Int = 32) {
        precondition(segments >= 3)
        self.radius = radius
        self.segments = segments
    }
    public var vertices: [Vector2<T>] {
        let n = segments
        let r = radius
        return (0..<n).map { i in
            let angle = T(i) * (2 * .pi) / T(n)
            return Vector2(r * T(cos(Double(angle))), r * T(sin(Double(angle))))
        }
    }
}

/// A polygon defined by an arbitrary list of points.  The points should be
/// provided in CCW order and should not self‑intersect.  No checking is
/// performed.
public struct Polygon<T: BinaryFloatingPoint>: Shape {
    public typealias Scalar = T
    public var points: [Vector2<T>]
    public init(points: [Vector2<T>]) {
        precondition(points.count >= 3, "A polygon requires at least three points.")
        self.points = points
    }
    public var vertices: [Vector2<T>] { points }
}
