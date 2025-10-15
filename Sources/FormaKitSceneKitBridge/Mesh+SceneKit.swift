//  FormaKit
//  Mesh+SceneKit.swift
//
//  Provides utilities for converting FormaKit3D meshes into SceneKit
//  geometries.  Only compiled when SceneKit is available.  This file
//  belongs to the FormaKitSceneKitBridge target.

#if ENABLE_SCENEKIT
import Foundation
import SceneKit
import FormaKit3D

fileprivate extension Data {
    init<T>(copyingBuffer buffer: [T]) {
        self = buffer.withUnsafeBytes { Data($0) }
    }
}

/// Convert a `Mesh<Double>` into an `SCNGeometry` with optional normals and
/// texture coordinates.  Positions and normals are provided as float3.
public func makeSCNGeometry(from mesh: Mesh<Double>) -> SCNGeometry {
    var sources: [SCNGeometrySource] = []
    // positions
    let positions: [Float] = mesh.vertices.flatMap { [Float($0.x), Float($0.y), Float($0.z)] }
    let posData = Data(copyingBuffer: positions)
    let posSource = SCNGeometrySource(data: posData,
                                       semantic: .vertex,
                                       vectorCount: mesh.vertices.count,
                                       usesFloatComponents: true,
                                       componentsPerVector: 3,
                                       bytesPerComponent: MemoryLayout<Float>.size,
                                       dataOffset: 0,
                                       dataStride: MemoryLayout<Float>.size * 3)
    sources.append(posSource)
    // normals
    if !mesh.normals.isEmpty {
        let normals: [Float] = mesh.normals.flatMap { [Float($0.x), Float($0.y), Float($0.z)] }
        let normData = Data(copyingBuffer: normals)
        let normSource = SCNGeometrySource(data: normData,
                                           semantic: .normal,
                                           vectorCount: mesh.normals.count,
                                           usesFloatComponents: true,
                                           componentsPerVector: 3,
                                           bytesPerComponent: MemoryLayout<Float>.size,
                                           dataOffset: 0,
                                           dataStride: MemoryLayout<Float>.size * 3)
        sources.append(normSource)
    }
    // UVs
    if !mesh.uvs.isEmpty {
        let uvs: [Float] = mesh.uvs.flatMap { [Float($0.x), Float($0.y)] }
        let uvData = Data(copyingBuffer: uvs)
        let uvSource = SCNGeometrySource(data: uvData,
                                         semantic: .texcoord,
                                         vectorCount: mesh.uvs.count,
                                         usesFloatComponents: true,
                                         componentsPerVector: 2,
                                         bytesPerComponent: MemoryLayout<Float>.size,
                                         dataOffset: 0,
                                         dataStride: MemoryLayout<Float>.size * 2)
        sources.append(uvSource)
    }
    // indices (16‑bit if possible, else 32‑bit)
    let maxIndex = mesh.indices.max() ?? 0
    let element: SCNGeometryElement
    if maxIndex < Int(UInt16.max) {
        let idx: [UInt16] = mesh.indices.map { UInt16($0) }
        let idxData = Data(copyingBuffer: idx)
        element = SCNGeometryElement(data: idxData,
                                     primitiveType: .triangles,
                                     primitiveCount: idx.count / 3,
                                     bytesPerIndex: MemoryLayout<UInt16>.size)
    } else {
        let idx: [UInt32] = mesh.indices.map { UInt32($0) }
        let idxData = Data(copyingBuffer: idx)
        element = SCNGeometryElement(data: idxData,
                                     primitiveType: .triangles,
                                     primitiveCount: idx.count / 3,
                                     bytesPerIndex: MemoryLayout<UInt32>.size)
    }
    return SCNGeometry(sources: sources, elements: [element])
}
#endif