//  FormaKit
//  Mesh.swift
//
//  Defines a generic mesh type storing vertex positions, normals, texture
//  coordinates and triangle indices.  Provides basic utilities such as
//  normal recomputation and transformation.  This file is part of the
//  FormaKit3D target.

import Foundation
import FormaKit2D

/// A triangle mesh consisting of vertices, optional normals/UVs and index data.
/// The mesh is generic over the underlying floating point scalar.  Indices are
/// stored as `Int` and reference into the vertex arrays.  All indices must
/// define triangles (multiples of three).  No validation is performed.
public struct Mesh<T: BinaryFloatingPoint>: Equatable, Sendable {
    public var vertices: [Vector3<T>]
    public var normals: [Vector3<T>]
    public var uvs: [Vector2<T>]
    public var indices: [Int]

    /// Create a mesh with the provided arrays.  The normals and uvs arrays
    /// should either be empty or have the same length as `vertices`.
    public init(vertices: [Vector3<T>], normals: [Vector3<T>] = [], uvs: [Vector2<T>] = [], indices: [Int]) {
        self.vertices = vertices
        self.normals = normals
        self.uvs = uvs
        self.indices = indices
    }

    /// Recompute normals if the `normals` array is empty.  Uses the face normal
    /// average per vertex algorithm.  The mesh must be composed of triangles.
    public mutating func computeNormalsIfEmpty() {
        guard normals.isEmpty else { return }
        normals = Array(repeating: Vector3<T>.zero, count: vertices.count)
        // accumulate face normals per vertex
        let count = indices.count
        var accum = Array(repeating: Vector3<T>.zero, count: vertices.count)
        var faceCount = Array(repeating: 0, count: vertices.count)
        var i = 0
        while i < count {
            let i0 = indices[i]
            let i1 = indices[i+1]
            let i2 = indices[i+2]
            let v0 = vertices[i0]
            let v1 = vertices[i1]
            let v2 = vertices[i2]
            let n = (v1 - v0).cross(v2 - v0)
            accum[i0] = accum[i0] + n
            accum[i1] = accum[i1] + n
            accum[i2] = accum[i2] + n
            faceCount[i0] += 1
            faceCount[i1] += 1
            faceCount[i2] += 1
            i += 3
        }
        for j in 0..<accum.count {
            let n = accum[j]
            normals[j] = n.normalized()
        }
    }

    /// Apply a transformation matrix to all vertices and optionally normals.
    public func transformed(by m: Matrix4<T>) -> Mesh<T> {
        var verts: [Vector3<T>] = []
        verts.reserveCapacity(vertices.count)
        for v in vertices { verts.append(m.transformPoint(v)) }
        var norms: [Vector3<T>] = []
        if !normals.isEmpty {
            norms.reserveCapacity(normals.count)
            // derive normal matrix from m (inverse transpose of upper 3x3)
            // For simplicity we use transformDirection and renormalize
            for n in normals {
                norms.append(m.transformDirection(n).normalized())
            }
        }
        return Mesh(vertices: verts, normals: norms, uvs: uvs, indices: indices)
    }

    /// Combine this mesh with another mesh and return the result.  The two
    /// meshes must use the same scalar type.  Indices of the second mesh are
    /// offset by the vertex count of the first.
    public func combined(with other: Mesh<T>) -> Mesh<T> {
        var newVerts = self.vertices + other.vertices
        var newNorms = self.normals
        if !other.normals.isEmpty {
            if newNorms.isEmpty { newNorms = Array(repeating: Vector3<T>.zero, count: newVerts.count) }
            newNorms += other.normals
        }
        var newUVs = self.uvs
        if !other.uvs.isEmpty {
            if newUVs.isEmpty { newUVs = Array(repeating: Vector2<T>.zero, count: newVerts.count) }
            newUVs += other.uvs
        }
        let offset = self.vertices.count
        var newIndices = self.indices + other.indices.map { $0 + offset }
        return Mesh(vertices: newVerts, normals: newNorms, uvs: newUVs, indices: newIndices)
    }
}
