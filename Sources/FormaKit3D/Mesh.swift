//  FormaKit
//  Mesh.swift

import Foundation
import FormaKit2D

/// A triangle mesh consisting of vertices, optional normals/UVs and triangle indices.
public struct Mesh<T: BinaryFloatingPoint>: Equatable {
    public var vertices: [Vector3<T>]
    public var normals: [Vector3<T>]
    public var uvs: [Vector2<T>]
    public var indices: [Int]

    /// Create a mesh with the provided arrays.
    public init(vertices: [Vector3<T>], normals: [Vector3<T>] = [], uvs: [Vector2<T>] = [], indices: [Int]) {
        self.vertices = vertices
        self.normals = normals
        self.uvs = uvs
        self.indices = indices
    }

    /// Recompute normals if `normals` is empty (face-normal average per vertex).
    public mutating func computeNormalsIfEmpty() {
        guard normals.isEmpty else { return }
        var accum = Array(repeating: Vector3<T>.zero, count: vertices.count)
        let count = indices.count
        var i = 0
        while i < count {
            let i0 = indices[i], i1 = indices[i+1], i2 = indices[i+2]
            let v0 = vertices[i0], v1 = vertices[i1], v2 = vertices[i2]
            let n = (v1 - v0).cross(v2 - v0)
            accum[i0] = accum[i0] + n
            accum[i1] = accum[i1] + n
            accum[i2] = accum[i2] + n
            i += 3
        }
        normals = accum.map { $0.normalized() }
    }

    /// Transform all vertices (and normals if present).
    public func transformed(by m: Matrix4<T>) -> Mesh<T> {
        var verts: [Vector3<T>] = []
        verts.reserveCapacity(vertices.count)
        for v in vertices { verts.append(m.transformPoint(v)) }

        var norms: [Vector3<T>] = []
        if !normals.isEmpty {
            norms.reserveCapacity(normals.count)
            for n in normals {
                norms.append(m.transformDirection(n).normalized())
            }
        }
        return Mesh(vertices: verts, normals: norms, uvs: uvs, indices: indices)
    }

    /// Combine this mesh with another (same scalar type).
    public func combined(with other: Mesh<T>) -> Mesh<T> {
        var newVerts = self.vertices + other.vertices
        var newNorms = self.normals
        if !other.normals.isEmpty {
            if newNorms.isEmpty { newNorms = Array(repeating: Vector3<T>.zero, count: newVerts.count - other.vertices.count) }
            newNorms += other.normals
        }
        var newUVs = self.uvs
        if !other.uvs.isEmpty {
            if newUVs.isEmpty { newUVs = Array(repeating: Vector2<T>.zero, count: newVerts.count - other.vertices.count) }
            newUVs += other.uvs
        }
        let offset = self.vertices.count
        let newIndices = self.indices + other.indices.map { $0 + offset }
        return Mesh(vertices: newVerts, normals: newNorms, uvs: newUVs, indices: newIndices)
    }
}

/// Swift 6: Sendable solo cuando T lo sea (y por ende Vector2/Vector3 también).
extension Mesh: Sendable where T: Sendable {}

