/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that creates a volume so that a person can create meshes with the location of the drag gesture.
*/

import SwiftUI
import RealityKit

/// A class that stores each stroke and generates a mesh, in real time, from a person's gesture movement.
class PaintingCanvas {
    /// The main root entity for the painting canvas.
    let root = Entity()

    /// The stroke that a person creates.
    var currentStroke: Stroke?

    /// The distance for the box that extends in the positive direction.
    let big: Float = 1E2
    
    /// The distance for the box that extends in the negative direction.
    let small: Float = 1E-2

    // Sets up the painting canvas with six collision boxes that stack on each other.
    init() {
        root.addChild(addBox(size: [big, big, small], position: [0, 0, -0.5 * big]))
        root.addChild(addBox(size: [big, big, small], position: [0, 0, +0.5 * big]))
        root.addChild(addBox(size: [big, small, big], position: [0, -0.5 * big, 0]))
        root.addChild(addBox(size: [big, small, big], position: [0, +0.5 * big, 0]))
        root.addChild(addBox(size: [small, big, big], position: [-0.5 * big, 0, 0]))
        root.addChild(addBox(size: [small, big, big], position: [+0.5 * big, 0, 0]))
    }

    /// Create a collision box that takes in user input with the drag gesture.
    private func addBox(size: SIMD3<Float>, position: SIMD3<Float>) -> Entity {
        /// The new entity for the box.
        let box = Entity()

        // Enable user inputs.
        box.components.set(InputTargetComponent())

        // Enable collisions for the box.
        box.components.set(CollisionComponent(shapes: [.generateBox(size: size)], isStatic: true))

        // Set the position of the box from the position value.
        box.position = position

        return box
    }

    /// Generate a point when the user uses the drag gesture.
    func addPoint(_ position: SIMD3<Float>) {
        /// The maximum distance between two points before requiring a new point.
        let threshold: Float = 1E-9

        // Start a new stroke if no stroke exists.
        if currentStroke == nil {
            currentStroke = Stroke()

            // Add the stroke to the root.
            root.addChild(currentStroke!.entity)
        }

        // Check whether the length between the current hand position and the previous point meets the threshold.
        if let previousPoint = currentStroke?.points.last, length(position - previousPoint) < threshold {
            return
        }

        // Add the current position to the stroke.
        currentStroke?.points.append(position)

        // Update the current stroke mesh.
        currentStroke?.updateMesh()
    }

    /// Clear the stroke when the drag gesture ends.
    func finishStroke() {
        if let stroke = currentStroke {
            // Trigger the update mesh operation.
            stroke.updateMesh()

            // Clear the current stroke.
            currentStroke = nil
        }
    }
}
