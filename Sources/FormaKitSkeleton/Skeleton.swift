//  FormaKit
//  Skeleton.swift
//
//  A skeleton is a collection of bones arranged in a hierarchy.  Each bone
//  includes an inverse bind transform that brings mesh vertices into bone
//  space.  A skeleton can compute global pose matrices by combining local
//  pose matrices with the hierarchy.

import Foundation
import FormaKit3D

/// A skeleton consisting of an ordered array of bones.  The indices of the
/// array define each bone's ID.  Bones reference their parent by index or
/// `nil` if they are root bones.  See `Bone` for details.
public struct Skeleton: Equatable, Sendable {
    public var bones: [Bone]

    public init(bones: [Bone]) {
        self.bones = bones
    }

    /// Compute the global pose matrices from an array of local pose matrices.
    /// The `localPoses` array must have the same count as `bones` and contains
    /// the transform of each bone relative to its parent in the current pose.
    /// Returns an array of global transforms in world space.
    public func globalPoses(from localPoses: [Matrix4<Double>]) -> [Matrix4<Double>] {
        precondition(localPoses.count == bones.count)
        var globals: [Matrix4<Double>] = Array(repeating: .identity, count: bones.count)
        for i in 0..<bones.count {
            let parent = bones[i].parent
            if let p = parent {
                globals[i] = globals[p] * localPoses[i]
            } else {
                globals[i] = localPoses[i]
            }
        }
        return globals
    }
}