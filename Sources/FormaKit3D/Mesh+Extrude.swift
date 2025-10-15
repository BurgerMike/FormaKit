//  FormaKit
//  Mesh+Extrude.swift
//
//  Adds utilities for extruding 2D shapes into 3D meshes.  The extrusion
//  creates a prism: the shape is duplicated at two different Y‑positions
//  (top and bottom) and the perimeter edges are connected with quads
//  (triangulated).  This file is part of the FormaKit3D target.

import Foundation
import FormaKit2D

public extension Mesh where T == Double {
    /// Extrude a 2D shape into a 3D prism of the specified height.  The shape
    /// must be defined in the XZ plane (Y is up).  The resulting mesh will
    /// have normals generated automatically.  The bottom face is at y=0 and
    /// the top face at y=height.
    static func extrude<S: Shape>(_ shape: S, height: Double) -> Mesh where S.Scalar == Double {
        let verts2D = shape.vertices
        let count = verts2D.count
        precondition(count >= 3, "Shape must have at least three vertices")
        var verts: [Vector3<Double>] = []
        verts.reserveCapacity(count * 2)
        // bottom vertices (y=0)
        for v in verts2D {
            verts.append(Vector3(v.x, 0, v.y))
        }
        // top vertices (y=height)
        for v in verts2D {
            verts.append(Vector3(v.x, height, v.y))
        }
        var indices: [Int] = []
        // side faces: connect each edge to form quads (two triangles)
        for i in 0..<count {
            let next = (i + 1) % count
            // bottom i -> top i -> top next
            indices += [i, i + count, next + count]
            // bottom i -> top next -> bottom next
            indices += [i, next + count, next]
        }
        // bottom face (fan triangulation around first vertex) reversed for normal down
        for i in 1..<(count-1) {
            indices += [0, i+1, i]
        }
        // top face (fan) normal up
        let offset = count
        for i in 1..<(count-1) {
            indices += [offset, offset + i, offset + i + 1]
        }
        var mesh = Mesh(vertices: verts, normals: [], uvs: [], indices: indices)
        mesh.computeNormalsIfEmpty()
        return mesh
    }
}