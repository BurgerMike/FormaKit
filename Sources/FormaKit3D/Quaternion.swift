//  FormaKit
//  Quaternion.swift

import Foundation
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// A quaternion representing a 3D rotation. Generic over the floating point scalar.
public struct Quaternion<T: BinaryFloatingPoint>: Equatable {
    public var x: T
    public var y: T
    public var z: T
    public var w: T

    /// Create a quaternion from components. Use normalized() if needed.
    @inlinable public init(x: T, y: T, z: T, w: T) {
        self.x = x; self.y = y; self.z = z; self.w = w
    }

    /// Identity quaternion (no rotation).
    @inlinable public static var identity: Quaternion { Quaternion(x: 0, y: 0, z: 0, w: 1) }

    /// From axis + angle (radians).
    @inlinable public static func fromAxis(_ axis: Vector3<T>, angleRadians: T) -> Quaternion {
        let n = axis.normalized()
        let half = angleRadians / 2
        let s = T(sin(Double(half)))
        return Quaternion(x: n.x * s, y: n.y * s, z: n.z * s, w: T(cos(Double(half))))
    }

    /// Composition (not commutative).
    @inlinable public static func *(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        Quaternion(
            x: lhs.w*rhs.x + lhs.x*rhs.w + lhs.y*rhs.z - lhs.z*rhs.y,
            y: lhs.w*rhs.y - lhs.x*rhs.z + lhs.y*rhs.w + lhs.z*rhs.x,
            z: lhs.w*rhs.z + lhs.x*rhs.y - lhs.y*rhs.x + lhs.z*rhs.w,
            w: lhs.w*rhs.w - lhs.x*rhs.x - lhs.y*rhs.y - lhs.z*rhs.z
        )
    }

    /// Normalized (identity if zero).
    @inlinable public func normalized() -> Quaternion {
        let len = (x*x + y*y + z*z + w*w).squareRoot()
        return len > 0 ? Quaternion(x: x/len, y: y/len, z: z/len, w: w/len) : .identity
    }

    /// Convert to column-major 4×4 rotation matrix.
    @inlinable public func toMatrix() -> Matrix4<T> {
        let q = normalized()
        let x = q.x, y = q.y, z = q.z, w = q.w
        let xx = x * x, yy = y * y, zz = z * z
        let xy = x * y, xz = x * z, yz = y * z
        let wx = w * x, wy = w * y, wz = w * z
        return Matrix4([
            1 - 2*(yy + zz), 2*(xy + wz),     2*(xz - wy),     0,
            2*(xy - wz),     1 - 2*(xx + zz), 2*(yz + wx),     0,
            2*(xz + wy),     2*(yz - wx),     1 - 2*(xx + yy), 0,
            0,               0,               0,               1
        ])
    }
}

/// Swift 6: Sendable solo cuando T lo sea.
extension Quaternion: Sendable where T: Sendable {}

