//  FormaKit
//  Mesh+Extrude.swift

import Foundation
import FormaKit2D

public extension Mesh where T == Double {
    /// Extrude a 2D shape into a 3D prism of the specified height (Y up).
    static func extrude<S: Shape>(_ shape: S, height: Double) -> Mesh where S.Scalar == Double {
        let verts2D = shape.vertices
        let count = verts2D.count
        precondition(count >= 3, "Shape must have at least three vertices")
        var verts: [Vector3<Double>] = []
        verts.reserveCapacity(count * 2)

        // bottom (y=0)
        for v in verts2D { verts.append(Vector3(v.x, 0, v.y)) }
        // top (y=height)
        for v in verts2D { verts.append(Vector3(v.x, height, v.y)) }

        var indices: [Int] = []
        // sides (two triangles per quad)
        for i in 0..<count {
            let next = (i + 1) % count
            indices += [i, i + count, next + count]
            indices += [i, next + count, next]
        }
        // bottom face (fan, reversed normal)
        for i in 1..<(count - 1) { indices += [0, i + 1, i] }
        // top face (fan, normal up)
        let offset = count
        for i in 1..<(count - 1) { indices += [offset, offset + i, offset + i + 1] }

        var mesh = Mesh(vertices: verts, normals: [], uvs: [], indices: indices)
        mesh.computeNormalsIfEmpty()
        return mesh
    }
}

