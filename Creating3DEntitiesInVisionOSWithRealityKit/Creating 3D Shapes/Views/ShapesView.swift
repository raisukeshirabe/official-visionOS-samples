/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays five different 3D shapes.
*/

import SwiftUI
import RealityKit

/// A view that displays predefined 3D shapes with white material in a row along the x-axis.
struct ShapesView: View {
    var body: some View {
        RealityView { content in
            addGeometryShapes(to: content)
        }
    }

    /// Add 3D shapes to the `RealityView` content.
    func addGeometryShapes(to content: RealityViewContent) {
        /// The array of all the 3D entities that represent different shapes.
        let allGeometryEntities = [
            ShapesView.boxEntity,
            ShapesView.roundedBoxEntity,
            ShapesView.sphereEntity,
            ShapesView.coneEntity,
            ShapesView.cylinderEntity
        ]

        /// The initial position along the x-axis for the first shape.
        var xOffset: Float = -0.25

        // Position the entities along the x-axis, and add to the content.
        for entity in allGeometryEntities {
            // Set the entity's position to the x-axis offset.
            entity.position.x = xOffset

            // Add the entity to the `RealityView` content.
            content.add(entity)

            // Increment the x-axis offset for the next entity.
            xOffset += 0.125
        }
    }
}

#Preview(windowStyle: .automatic) {
    ShapesView()
}
