/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that draws a triangle.
*/

import SwiftUI

/// A shape view that draws itself as a right, isoscolese triangle.
struct Triangle: Shape {
    let vertex1: CGPoint
    let vertex2: CGPoint
    let vertex3: CGPoint

    init(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) {
        vertex1 = point1
        vertex2 = point2
        vertex3 = point3
    }

    func path(in bounds: CGRect) -> Path {
        /// The drawing path for the triangle shape.
        var path = Path()

        // Start at the first vertex.
        path.move(to: vertex1)

        // Draw the triangle's first two sides.
        path.addLine(to: vertex2)
        path.addLine(to: vertex3)
        
        // Draw the triangle's third side by returning to the first vertex.
        path.closeSubpath()

        return path
    }
}
