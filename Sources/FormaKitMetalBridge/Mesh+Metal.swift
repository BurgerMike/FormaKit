//  FormaKit
//  Mesh+Metal.swift
//
//  Provides utilities for converting FormaKit3D meshes into Metal buffers.
//  Compiles only when Metal is available.  Belongs to the FormaKitMetalBridge target.

#if canImport(Metal)
import Foundation
import Metal
import simd
import FormaKit3D
import FormaKit2D

public struct MetalMeshBuffers {
    public let vbPositions: MTLBuffer
    public let vbNormals:   MTLBuffer?
    public let vbUVs:       MTLBuffer?
    public let ib:          MTLBuffer
    public let indexCount:  Int
    public let indexType:   MTLIndexType
}

/// Convenience vertex descriptor matching the buffer layout we create:
/// - attr(0): float3 position in buffer(0)
/// - attr(1): float3 normal   in buffer(1), if present
/// - attr(2): float2 uv       in buffer(2), if present
public func makeStandardVertexDescriptor(hasNormals: Bool, hasUVs: Bool) -> MTLVertexDescriptor {
    let vd = MTLVertexDescriptor()
    // positions
    vd.attributes[0].format = .float3
    vd.attributes[0].offset = 0
    vd.attributes[0].bufferIndex = 0
    vd.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
    vd.layouts[0].stepFunction = .perVertex

    if hasNormals {
        vd.attributes[1].format = .float3
        vd.attributes[1].offset = 0
        vd.attributes[1].bufferIndex = 1
        vd.layouts[1].stride = MemoryLayout<SIMD3<Float>>.stride
        vd.layouts[1].stepFunction = .perVertex
    }

    if hasUVs {
        vd.attributes[2].format = .float2
        vd.attributes[2].offset = 0
        vd.attributes[2].bufferIndex = 2
        vd.layouts[2].stride = MemoryLayout<SIMD2<Float>>.stride
        vd.layouts[2].stepFunction = .perVertex
    }
    return vd
}

// MARK: - Public overloads

@inlinable
public func makeMetalBuffers(device: MTLDevice, mesh: Mesh<Double>) -> MetalMeshBuffers {
    return _makeMetalBuffers(device: device, mesh: mesh) { Float($0) }
}

@inlinable
public func makeMetalBuffers(device: MTLDevice, mesh: Mesh<Float>) -> MetalMeshBuffers {
    return _makeMetalBuffers(device: device, mesh: mesh) { $0 }
}

// MARK: - Generic core (internal)

@inlinable
func _makeMetalBuffers<T: BinaryFloatingPoint>(
    device: MTLDevice,
    mesh: Mesh<T>,
    _ f: (T) -> Float
) -> MetalMeshBuffers {

    precondition(!mesh.vertices.isEmpty, "Mesh has no vertices")

    // Positions (float3)
    let positions: [SIMD3<Float>] = mesh.vertices.map { .init(f($0.x), f($0.y), f($0.z)) }
    guard let vbP = device.makeBuffer(bytes: positions,
                                      length: positions.count * MemoryLayout<SIMD3<Float>>.stride,
                                      options: []) else {
        fatalError("Failed to create positions buffer")
    }
    vbP.label = "VB Positions"

    // Normals (float3, optional)
    var vbN: MTLBuffer? = nil
    if !mesh.normals.isEmpty {
        let normals: [SIMD3<Float>] = mesh.normals.map { .init(f($0.x), f($0.y), f($0.z)) }
        vbN = device.makeBuffer(bytes: normals,
                                length: normals.count * MemoryLayout<SIMD3<Float>>.stride,
                                options: [])
        vbN?.label = "VB Normals"
    }

    // UVs (float2, optional)
    var vbU: MTLBuffer? = nil
    if !mesh.uvs.isEmpty {
        let uvs: [SIMD2<Float>] = mesh.uvs.map { .init(f($0.x), f($0.y)) }
        vbU = device.makeBuffer(bytes: uvs,
                                length: uvs.count * MemoryLayout<SIMD2<Float>>.stride,
                                options: [])
        vbU?.label = "VB UVs"
    }

    // Choose 16-bit or 32-bit indices
    let maxIndex = (mesh.indices.max() ?? 0)
    let use16 = maxIndex <= Int(UInt16.max)

    let indexType: MTLIndexType = use16 ? .uint16 : .uint32
    let ib: MTLBuffer
    if use16 {
        let idx16 = mesh.indices.map { UInt16(truncatingIfNeeded: $0) }
        ib = device.makeBuffer(bytes: idx16,
                               length: idx16.count * MemoryLayout<UInt16>.stride,
                               options: [])!
    } else {
        let idx32 = mesh.indices.map { UInt32(truncatingIfNeeded: $0) }
        ib = device.makeBuffer(bytes: idx32,
                               length: idx32.count * MemoryLayout<UInt32>.stride,
                               options: [])!
    }
    ib.label = "Index Buffer"

    return MetalMeshBuffers(
        vbPositions: vbP,
        vbNormals: vbN,
        vbUVs: vbU,
        ib: ib,
        indexCount: mesh.indices.count,
        indexType: indexType
    )
}

#endif

