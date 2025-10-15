//  FormaKit
//  Mesh+Metal.swift
//
//  Provides utilities for converting FormaKit3D meshes into Metal buffers.
//  Only compiled when Metal is available.  This file belongs to the
//  FormaKitMetalBridge target.

#if ENABLE_METAL
import Foundation
import Metal
import FormaKit3D

/// Container for Metal buffer references corresponding to a mesh.
public struct MetalMeshBuffers {
    public let vbPositions: MTLBuffer
    public let vbNormals:   MTLBuffer?
    public let vbUVs:       MTLBuffer?
    public let ib:          MTLBuffer
    public let indexCount:  Int
}

/// Create Metal buffers for the given mesh.  Positions are stored as
/// `float3`, normals as `float3` if present, and UVs as `float2`.  Indices
/// are stored as `uint32_t`.  The caller is responsible for setting the
/// appropriate vertex descriptor and pipeline state to match the buffer
/// layouts.
public func makeMetalBuffers(device: MTLDevice, mesh: Mesh<Double>) -> MetalMeshBuffers {
    // positions
    let positions = mesh.vertices.map { SIMD3<Float>(Float($0.x), Float($0.y), Float($0.z)) }
    let vbP = device.makeBuffer(bytes: positions,
                                length: positions.count * MemoryLayout<SIMD3<Float>>.stride,
                                options: [])!
    // normals
    var vbN: MTLBuffer? = nil
    if !mesh.normals.isEmpty {
        let normals = mesh.normals.map { SIMD3<Float>(Float($0.x), Float($0.y), Float($0.z)) }
        vbN = device.makeBuffer(bytes: normals,
                                length: normals.count * MemoryLayout<SIMD3<Float>>.stride,
                                options: [])
    }
    // uvs
    var vbU: MTLBuffer? = nil
    if !mesh.uvs.isEmpty {
        let uvs = mesh.uvs.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        vbU = device.makeBuffer(bytes: uvs,
                                length: uvs.count * MemoryLayout<SIMD2<Float>>.stride,
                                options: [])
    }
    // indices
    let indices = mesh.indices.map { UInt32($0) }
    let ib = device.makeBuffer(bytes: indices,
                               length: indices.count * MemoryLayout<UInt32>.stride,
                               options: [])!
    return MetalMeshBuffers(vbPositions: vbP,
                            vbNormals: vbN,
                            vbUVs: vbU,
                            ib: ib,
                            indexCount: indices.count)
}
#endif