/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that draws a dashed line.
*/

import SwiftUI

/// A shape view that draws itself as a line.
struct Line: Shape {
    let endPoint1: CGPoint
    let endPoint2: CGPoint

    init(_ length: CGFloat) {
        let point = CGPoint(x: length, y: 0.0)
        self.init(point)
    }

    init(_ point1: CGPoint, _ point2: CGPoint? = nil) {
        if let point2 {
            endPoint1 = point1
            endPoint2 = point2
        } else {
            endPoint1 = CGPoint.zero
            endPoint2 = point1
        }
    }

    func path(in bounds: CGRect) -> Path {
        /// The drawing path for the triangle shape.
        var path = Path()
        
        // Draw the line between the two endpoints.
        path.move(to: endPoint1)
        path.addLine(to: endPoint2)

        return path
    }
}

extension Line {
    func dashed(_ width: CGFloat,
                _ dashPattern: [CGFloat]? = nil) -> some Shape {
        let pattern = dashPattern ?? [width]
        let style = StrokeStyle(lineWidth: width, dash: pattern)

        return stroke(style: style)
    }
}
