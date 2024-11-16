/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that draws multiple shapes.
*/

import SwiftUI

/// A view that creates and displays multiple shapes in the app's main view.
struct ShapesView: View {
    var body: some View {
        /// The gap between each shape.
        let spaceBetweenShapes: CGFloat = 30.0

        /// The width and height for the frame of each shape view.
        let shapeScale: CGFloat = 100.0

        /// A width for all the lines in each shape.
        let strokeWidth: CGFloat = 5.0

        /// The upper-leading corner of the triangle.
        let vertex1 = CGPoint(x: 0.0, y: 0.0)

        /// The lower-trailing corner of the triangle.
        let vertex2 = CGPoint(x: shapeScale, y: shapeScale)

        /// The lower-leading corner of the triangle.
        let vertex3 = CGPoint(x: 0.0, y: shapeScale)

        /// A pattern for the dashed line.
        let strokePattern = [3 * strokeWidth, 2 * strokeWidth]

        HStack(spacing: spaceBetweenShapes) {
            Circle()
                .stroke(lineWidth: strokeWidth)
                .frame(width: shapeScale, height: shapeScale)
            Rectangle()
                .stroke(lineWidth: strokeWidth)
                .frame(width: shapeScale, height: shapeScale)
            Triangle(vertex1, vertex2, vertex3)
                .stroke(lineWidth: strokeWidth)
                .frame(width: shapeScale, height: shapeScale)
            Line(shapeScale)
                .dashed(strokeWidth, strokePattern)
                .frame(width: shapeScale, height: shapeScale)
        }
    }
}
