//  FormaKit
//  Shape+CGPath.swift
//
//  Conversion between FormaKit2D shapes and Core Graphics paths.
//  Compiles only when CoreGraphics is available (Apple platforms).

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics
import FormaKit2D

// MARK: - Double-backed shapes → CGPath

public extension Shape where Scalar == Double {
    /// Creates a CGPath from this shape's vertices (assumed CCW, closed).
    /// - Parameter transform: Optional CGAffineTransform to apply on the fly.
    @inlinable
    func cgPath(transform: CGAffineTransform? = nil) -> CGPath {
        let path = CGMutablePath()
        guard let first = vertices.first else { return path }
        path.move(to: CGPoint(x: first.x, y: first.y), transform: transform ?? .identity)
        for v in vertices.dropFirst() {
            path.addLine(to: CGPoint(x: v.x, y: v.y), transform: transform ?? .identity)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - CGFloat-backed shapes → CGPath

public extension Shape where Scalar == CGFloat {
    /// Creates a CGPath from this shape's vertices (assumed CCW, closed).
    /// - Parameter transform: Optional CGAffineTransform to apply on the fly.
    @inlinable
    func cgPath(transform: CGAffineTransform? = nil) -> CGPath {
        let path = CGMutablePath()
        guard let first = vertices.first else { return path }
        path.move(to: CGPoint(x: first.x, y: first.y), transform: transform ?? .identity)
        for v in vertices.dropFirst() {
            path.addLine(to: CGPoint(x: v.x, y: v.y), transform: transform ?? .identity)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Optional: CGPath → Polygon<Double> (flattened)
// Descomenta si quieres reconstruir un polígono desde un CGPath (approx).
// Requiere que el path sea una única subruta cerrada sin curvas.
//
// public extension Polygon where Scalar == Double {
//     @inlinable
//     init?(cgPath: CGPath) {
//         var pts: [Vector2<Double>] = []
//         var ok = true
//         cgPath.applyWithBlock { elementPtr in
//             let e = elementPtr.pointee
//             switch e.type {
//             case .moveToPoint:
//                 pts.removeAll()
//                 pts.append(Vector2(Double(e.points[0].x), Double(e.points[0].y)))
//             case .addLineToPoint:
//                 pts.append(Vector2(Double(e.points[0].x), Double(e.points[0].y)))
//             case .closeSubpath:
//                 break
//             default:
//                 // Curves not supported in simple polygon reconstruction
//                 ok = false
//             }
//         }
//         guard ok, pts.count >= 3 else { return nil }
//         self.init(points: pts)
//     }
// }

#endif

