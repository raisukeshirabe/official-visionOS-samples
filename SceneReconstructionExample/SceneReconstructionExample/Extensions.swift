/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Helper functions for converting between ARKit and RealityKit types.
*/

import ARKit
import RealityKit

extension ModelEntity {
    /// Creates an invisible sphere that can interact with dropped cubes in the scene.
    class func createFingertip() -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius: 0.005),
            materials: [UnlitMaterial(color: .cyan)],
            collisionShape: .generateSphere(radius: 0.005),
            mass: 0.0)

        entity.components.set(PhysicsBodyComponent(mode: .kinematic))
        entity.components.set(OpacityComponent(opacity: 0.0))

        return entity
    }
}
