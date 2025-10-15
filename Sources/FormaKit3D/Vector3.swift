//  FormaKit
//  Vector3.swift
//
//  Created by FormaKit authors.  Provides a generic 3D vector type with
//  basic arithmetic operations and common vector math.  This file is part of
//  the FormaKit3D target.

import Foundation

/// A three‑component vector.  Generic over the underlying floating point type.
public struct Vector3<T: FloatingPoint>: Equatable, Sendable {
    public var x: T
    public var y: T
    public var z: T

    /// Create a vector with the given components.
    @inlinable public init(_ x: T, _ y: T, _ z: T) {
        self.x = x
        self.y = y
        self.z = z
    }

    /// A zero vector.
    @inlinable public static var zero: Vector3 { Vector3(0, 0, 0) }

    // Basic arithmetic operations
    @inlinable public static func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    @inlinable public static func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    @inlinable public static func *(lhs: Vector3, rhs: T) -> Vector3 {
        Vector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    @inlinable public static func *(lhs: T, rhs: Vector3) -> Vector3 {
        Vector3(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
    }
    @inlinable public static func /(lhs: Vector3, rhs: T) -> Vector3 {
        Vector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }

    /// Dot (scalar) product.
    @inlinable public func dot(_ other: Vector3) -> T {
        return x * other.x + y * other.y + z * other.z
    }

    /// Cross (vector) product.
    @inlinable public func cross(_ other: Vector3) -> Vector3 {
        return Vector3(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        )
    }

    /// Length (magnitude) of the vector.
    @inlinable public var length: T {
        return (x * x + y * y + z * z).squareRoot()
    }

    /// Returns a normalized copy of this vector.  If the vector is zero length,
    /// returns the zero vector.
    @inlinable public func normalized() -> Vector3 {
        let len = self.length
        return len > 0 ? self / len : .zero
    }
}