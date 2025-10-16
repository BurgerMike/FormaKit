//  FormaKit
//  RigidBody.swift
//
//  A simple rigid body for simulation purposes.  Each rigid body stores
//  position, velocity and applies forces over time.  No collision detection
//  beyond sphere–sphere interaction is provided.  This file belongs to the
//  FormaKitPhysics target.

import Foundation
import FormaKit3D

@MainActor // opcional pero útil si lo manejas desde UI/main
public final class RigidBody<T: FloatingPoint> {
    public var position: Vector3<T>
    public var velocity: Vector3<T>
    public var mass: T
    public var forces: Vector3<T>
    public var radius: T

    public init(position: Vector3<T> = .zero,
                velocity: Vector3<T> = .zero,
                mass: T = T(1),
                radius: T = T(1)) {
        self.position = position
        self.velocity = velocity
        self.mass = mass
        self.forces = .zero
        self.radius = radius
    }

    @inlinable public func applyForce(_ f: Vector3<T>) {
        forces = forces + f
    }

    @inlinable public func integrate(dt: T, gravity: Vector3<T> = .zero) {
        let acc = (forces / mass) + gravity
        velocity = velocity + acc * dt
        position = position + velocity * dt
        forces = .zero
    }

    @inlinable public func collideSphere(with other: inout RigidBody<T>) {
        let delta = other.position - position
        let dist = delta.length
        let minDist = radius + other.radius
        guard dist != 0 && dist < minDist else { return }
        let n = delta / dist
        let penetration = minDist - dist
        let inv1 = T(1) / mass
        let inv2 = T(1) / other.mass
        let totalInv = inv1 + inv2
        position      = position      - n * (penetration * (inv1 / totalInv))
        other.position = other.position + n * (penetration * (inv2 / totalInv))
        let relative = other.velocity - velocity
        let vn = relative.dot(n)
        if vn < 0 {
            let restitution: T = T(3) / T(5)
            let j = -(T(1) + restitution) * vn / totalInv
            let impulse = n * j
            velocity      = velocity      - impulse * inv1
            other.velocity = other.velocity + impulse * inv2
        }
    }
}

extension RigidBody: Sendable where T: Sendable {}
