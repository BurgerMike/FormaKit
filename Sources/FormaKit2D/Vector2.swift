//  FormaKit
//  Vector2.swift

import Foundation

/// A two-component vector. Generic over the underlying floating point type.
public struct Vector2<T: FloatingPoint>: Equatable {
    public var x: T
    public var y: T

    /// Create a vector with the given components.
    @inlinable public init(_ x: T, _ y: T) {
        self.x = x
        self.y = y
    }

    /// A zero vector.
    @inlinable public static var zero: Vector2 { Vector2(0, 0) }

    // Basic arithmetic operations
    @inlinable public static func +(lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    @inlinable public static func -(lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    @inlinable public static func *(lhs: Vector2, rhs: T) -> Vector2 {
        Vector2(lhs.x * rhs, lhs.y * rhs)
    }
    @inlinable public static func *(lhs: T, rhs: Vector2) -> Vector2 {
        Vector2(lhs * rhs.x, lhs * rhs.y)
    }
    @inlinable public static func /(lhs: Vector2, rhs: T) -> Vector2 {
        Vector2(lhs.x / rhs, lhs.y / rhs)
    }

    @inlinable public mutating func add(_ other: Vector2) {
        self.x += other.x; self.y += other.y
    }
    @inlinable public mutating func subtract(_ other: Vector2) {
        self.x -= other.x; self.y -= other.y
    }
    @inlinable public mutating func scale(by s: T) {
        self.x *= s; self.y *= s
    }

    /// Dot (scalar) product.
    @inlinable public func dot(_ other: Vector2) -> T {
        x * other.x + y * other.y
    }

    /// Length (magnitude) of the vector.
    @inlinable public var length: T {
        (x * x + y * y).squareRoot()
    }

    /// Normalized copy (zero if length is 0).
    @inlinable public func normalized() -> Vector2 {
        let len = length
        return len > 0 ? self / len : .zero
    }
}

/// Swift 6: Sendable solo cuando T lo sea (evita el error de concurrencia).
extension Vector2: Sendable where T: Sendable {}

