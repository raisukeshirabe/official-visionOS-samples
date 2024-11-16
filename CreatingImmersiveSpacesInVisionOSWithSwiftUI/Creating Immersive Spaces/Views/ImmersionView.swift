/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A RealityKit view that creates a ring of asteroids that orbit around the person.
*/

import SwiftUI
import RealityKit

/// A view that creates an entity filled with rocks that rotate around the average height of a human.
struct ImmersiveView: View {
    /// The average human height in meters.
    let avgHeight: Float = 1.70

    /// The rate of movement at which the rocks orbit.
    let speed: TimeInterval = 0.03

    var body: some View {
        // Initiate a `RealityView` to create a ring
        // of rocks to orbit around a person.
        RealityView { content in
            /// The entity to contain the models.
            let rootEntity = Entity()

            // Set the y-axis position to the average human height.
            rootEntity.position.y += avgHeight

            // Create the halo effect with the `addHalo` method.
            rootEntity.addHalo()

            // Set the rotation speed for the rocks.
            rootEntity.components.set(TurnTableComponent(speed: speed))

            // Register the `TurnTableSystem` to handle the rotation logic.
            TurnTableSystem.registerSystem()

            // Add the entity to the view.
            content.add(rootEntity)
        }
    }
}
