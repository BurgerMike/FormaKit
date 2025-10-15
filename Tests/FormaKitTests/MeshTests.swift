import XCTest
@testable import FormaKit2D
@testable import FormaKit3D

final class MeshTests: XCTestCase {
    /// Test extruding a rectangle into a simple box.
    func testExtrudeRectangle() {
        let rect = Rectangle<Double>(width: 2.0, height: 1.0)
        let mesh = Mesh<Double>.extrude(rect, height: 3.0)
        // expect 8 vertices (4 bottom + 4 top)
        XCTAssertEqual(mesh.vertices.count, 8)
        // expect 12 triangles (8 side, 2 bottom, 2 top) → 36 indices
        XCTAssertEqual(mesh.indices.count, 36)
        // compute normals should not crash
        var mesh2 = mesh
        mesh2.computeNormalsIfEmpty()
        XCTAssertEqual(mesh2.normals.count, 8)
    }
}