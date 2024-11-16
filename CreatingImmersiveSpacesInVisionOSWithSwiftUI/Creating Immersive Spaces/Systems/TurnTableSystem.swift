/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system and component allowing entities to orbit around a set axis.
*/

import SwiftUI
import RealityKit

/// A component that enables an entity to rotate in an orbit over time.
struct TurnTableComponent: Component {
    /// The duration of the orbit effect.
    var time: TimeInterval = 0

    /// The speed at which the entity moves over time.
    var speed: TimeInterval

    /// The axis that the object orbits.
    var axis: SIMD3<Float>

    /// Initialize the turntable component by setting the speed and axis variables.
    init(speed: TimeInterval = 1.0, axis: SIMD3<Float> = [0, 1, 0]) {
        self.speed = speed
        self.axis = axis
    }
}

/// A system that checks for entities containing the `TurnTableComponent` and updates the time and orientation.
struct TurnTableSystem: System {
    /// The value to check if the entity has the required component.
    static let query = EntityQuery(where: .has(TurnTableComponent.self))

    /// Initialize the system with the RealityKit scene.
    init(scene: RealityKit.Scene) { }

    // Update the entities to apply the time value and orientation.
    func update(context: SceneUpdateContext) {
        // Iterate over entities that match the query and are currently rendering.
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            /// The variable to get the `TurnTableComponent` from the entity.
            var comp = entity.components[TurnTableComponent.self]!

            // Set the time variable to increase as time passes.
            comp.time += context.deltaTime

            // Update the component in the entity.
            entity.components[TurnTableComponent.self] = comp

            // Adjust the orientation to update the angle, speed, and axis of rotation.
            entity.setOrientation(simd_quatf(angle: Float(0.1 * comp.speed), axis: comp.axis), relativeTo: entity)
        }
    }
}
