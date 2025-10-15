//  FormaKit
//  Bone.swift
//
//  Defines a simple bone structure for skeletal animation.  Each bone has a
//  name, an optional parent index, and a bind pose transform that brings
//  vertices into bone space.  Bones are stored in an array inside a Skeleton.

import Foundation
import FormaKit3D

/// A single bone in a skeleton hierarchy.  Bones are referenced by index
/// within the skeleton.  The `parent` property refers to the index of the
/// parent bone or `nil` if the bone is a root.
public struct Bone: Equatable, Sendable {
    public var name: String
    public var parent: Int?
    /// The inverse bind transform.  When binding a mesh, vertices are
    /// transformed into the local space of the bone by this matrix.
    public var inverseBindTransform: Matrix4<Double>

    public init(name: String, parent: Int?, inverseBindTransform: Matrix4<Double>) {
        self.name = name
        self.parent = parent
        self.inverseBindTransform = inverseBindTransform
    }
}