//  FormaKit
//  Matrix4.swift
//
//  A simple 4×4 matrix type for affine transformations in 3D.  The matrix is
//  stored in column‑major order to match Metal/SceneKit/GL conventions.  It
//  includes factory methods for identity, translation, scale and rotation as
//  well as multiplication.  This file is part of the FormaKit3D target.

import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// A 4×4 matrix representing an affine transformation.  Generic over the
/// underlying floating point scalar.
public struct Matrix4<T: BinaryFloatingPoint>: Equatable, Sendable {
    /// The elements of the matrix in column‑major order.  `m[0]..m[3]` form
    /// the first column, `m[4]..m[7]` the second, etc.
    public var m: [T]

    /// Create a matrix from an array of 16 elements.  The array is used
    /// directly; no copying is performed.
    @inlinable public init(_ m: [T]) {
        precondition(m.count == 16)
        self.m = m
    }

    /// Identity matrix.
    @inlinable public static var identity: Matrix4 {
        return Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ])
    }

    /// Create a translation matrix.
    @inlinable public static func translation(_ t: Vector3<T>) -> Matrix4 {
        return Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            t.x, t.y, t.z, 1
        ])
    }

    /// Create a scale matrix.
    @inlinable public static func scale(_ s: Vector3<T>) -> Matrix4 {
        return Matrix4([
            s.x, 0,   0,   0,
            0,   s.y, 0,   0,
            0,   0,   s.z, 0,
            0,   0,   0,   1
        ])
    }

    /// Create a rotation matrix about an axis by an angle in radians.
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
                    let a = lhs.m[k*4 + row]   // column‑major: lhs[k][row]
                    let b = rhs.m[col*4 + k]   // rhs[col][k]
                    sum += a * b
                }
                out[col*4 + row] = sum
            }
        }
        return Matrix4(out)
    }

    /// Transform a point by this matrix.  Treats the point as having a
    /// homogeneous coordinate of 1.
    @inlinable public func transformPoint(_ p: Vector3<T>) -> Vector3<T> {
        let x = p.x, y = p.y, z = p.z
        let m = self.m
        let tx = m[0]*x + m[4]*y + m[8]*z  + m[12]
        let ty = m[1]*x + m[5]*y + m[9]*z  + m[13]
        let tz = m[2]*x + m[6]*y + m[10]*z + m[14]
        let w  = m[3]*x + m[7]*y + m[11]*z + m[15]
        if w != 0 { return Vector3(tx/w, ty/w, tz/w) }
        return Vector3(tx, ty, tz)
    }

    /// Transform a direction vector by this matrix.  Ignores translation.
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
