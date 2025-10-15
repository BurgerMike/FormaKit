//  FormaKit
//  SkinnedMesh.swift
//
//  A skinned mesh associates each vertex with a set of bone influences
//  (weights).  Given a skeleton and a set of bone pose matrices, it can
//  produce deformed vertex positions via linear blend skinning.  This file
//  belongs to the FormaKitSkeleton target.

import Foundation
import FormaKit3D

/// A weight describing how strongly a bone influences a vertex.  Each vertex
/// may be influenced by up to four bones for typical GPU skinning, but this
/// implementation supports any number of influences.
public struct SkinWeight: Equatable, Sendable {
    public var boneIndex: Int
    public var weight: Double
    public init(boneIndex: Int, weight: Double) {
        self.boneIndex = boneIndex
        self.weight = weight
    }
}

/// A mesh associated with a skeleton and per‑vertex weights.  The `weights`
/// array has the same count as the mesh's vertices.  Each entry is a list of
/// weights referencing bones by index and specifying how much influence each
/// bone has on that vertex.  The skeleton's bones contain inverse bind
/// transforms used to bring vertices into bone space before posing.
public struct SkinnedMesh: Sendable {
    public var mesh: Mesh<Double>
    public var skeleton: Skeleton
    public var weights: [[SkinWeight]]

    public init(mesh: Mesh<Double>, skeleton: Skeleton, weights: [[SkinWeight]]) {
        precondition(weights.count == mesh.vertices.count, "Weights count must match vertex count")
        self.mesh = mesh
        self.skeleton = skeleton
        self.weights = weights
    }

    /// Deform the mesh by applying the given local bone poses.  Returns an array
    /// of new vertex positions after skinning.  Local poses are transforms
    /// relative to the bind pose.  The skeleton will convert them to global
    /// matrices internally.  For each vertex, the final position is the sum
    /// over weights of (globalPose * inverseBindTransform * originalVertex).
    public func skinnedVertices(localPoses: [Matrix4<Double>]) -> [Vector3<Double>] {
        let globalPoses = skeleton.globalPoses(from: localPoses)
        var out: [Vector3<Double>] = Array(repeating: .zero, count: mesh.vertices.count)
        for (i, orig) in mesh.vertices.enumerated() {
            var acc = Vector3<Double>.zero
            for w in weights[i] {
                let boneIndex = w.boneIndex
                let weight = w.weight
                let invBind = skeleton.bones[boneIndex].inverseBindTransform
                let global = globalPoses[boneIndex]
                // bring original into bone space, apply pose, transform back to model
                let vInBone = invBind.transformPoint(orig)
                let vPosed = global.transformPoint(vInBone)
                acc = acc + vPosed * weight
            }
            out[i] = acc
        }
        return out
    }
}