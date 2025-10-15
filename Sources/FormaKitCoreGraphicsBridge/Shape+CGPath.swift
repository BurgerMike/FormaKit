//  FormaKit
//  Shape+CGPath.swift
//
//  Provides conversion routines between FormaKit2D shapes and Core Graphics
//  paths.  These functions are only compiled when CoreGraphics is available.

#if ENABLE_COREGRAPHICS
import Foundation
import CoreGraphics
import FormaKit2D

public extension Shape where Scalar == Double {
    /// Convert this shape into a CGPath.  The shape vertices are assumed to
    /// lie in the X–Y plane.  The path is closed automatically.
    func cgPath() -> CGPath {
        let path = CGMutablePath()
        guard let first = vertices.first else { return path }
        path.move(to: CGPoint(x: first.x, y: first.y))
        for v in vertices.dropFirst() {
            path.addLine(to: CGPoint(x: v.x, y: v.y))
        }
        path.closeSubpath()
        return path
    }
}
#endif