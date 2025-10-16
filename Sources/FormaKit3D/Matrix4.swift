//  FormaKit
//  Matrix4.swift

import Foundation
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// A 4×4 matrix representing an affine transformation. Generic over the scalar.
public struct Matrix4<T: BinaryFloatingPoint>: Equatable {
    /// Column-major storage (m[0...3] first column, etc.)
    public var m: [T]

    /// Create a matrix from 16 elements (no copying).
    @inlinable public init(_ m: [T]) {
        precondition(m.count == 16)
        self.m = m
    }

    /// Identity matrix.
    @inlinable public static var identity: Matrix4 {
        Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ])
    }

    /// Translation.
    @inlinable public static func translation(_ t: Vector3<T>) -> Matrix4 {
        Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            t.x, t.y, t.z, 1
        ])
    }

    /// Scale.
    @inlinable public static func scale(_ s: Vector3<T>) -> Matrix4 {
        Matrix4([
            s.x, 0,   0,   0,
            0,   s.y, 0,   0,
            0,   0,   s.z, 0,
            0,   0,   0,   1
        ])
    }

    /// Rotation about axis by angle (radians).
    @inlinable public static func rotation(axis: Vector3<T>, angleRadians: T) -> Matrix4 {
        let n = axis.normalized()
        let x = n.x, y = n.y, z = n.z
        let c = T(cos(Double(angleRadians)))
        let s = T(sin(Double(angleRadians)))
        let t = 1 - c
        return Matrix4([
            t*x*x + c,     t*x*y - s*z,  t*x*z + s*y,  0,
            t*x*y + s*z,  t*y*y + c,     t*y*z - s*x,  0,
            t*x*z - s*y,  t*y*z + s*x,  t*z*z + c,     0,
            0,            0,            0,            1
        ])
    }

    /// Matrix multiplication.
    @inlinable public static func *(lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
        var out: [T] = Array(repeating: 0, count: 16)
        for row in 0..<4 {
            for col in 0..<4 {
                var sum: T = 0
                for k in 0..<4 {
                    let a = lhs.m[k*4 + row]   // column-major: lhs[k][row]
                    let b = rhs.m[col*4 + k]   // rhs[col][k]
                    sum += a * b
                }
                out[col*4 + row] = sum
            }
        }
        return Matrix4(out)
    }

    /// Transform a point (homogeneous w = 1).
    @inlinable public func transformPoint(_ p: Vector3<T>) -> Vector3<T> {
        let x = p.x, y = p.y, z = p.z
        let m = self.m
        let tx = m[0]*x + m[4]*y + m[8]*z  + m[12]
        let ty = m[1]*x + m[5]*y + m[9]*z  + m[13]
        let tz = m[2]*x + m[6]*y + m[10]*z + m[14]
        let w  = m[3]*x + m[7]*y + m[11]*z + m[15]
        return w != 0 ? Vector3(tx/w, ty/w, tz/w) : Vector3(tx, ty, tz)
    }

    /// Transform a direction (ignores translation).
    @inlinable public func transformDirection(_ d: Vector3<T>) -> Vector3<T> {
        let x = d.x, y = d.y, z = d.z
        let m = self.m
        return Vector3(
            m[0]*x + m[4]*y + m[8]*z,
            m[1]*x + m[5]*y + m[9]*z,
            m[2]*x + m[6]*y + m[10]*z
        )
    }
}

/// Swift 6: Sendable solo cuando T lo sea (y el array de elementos también).
extension Matrix4: Sendable where T: Sendable {}

