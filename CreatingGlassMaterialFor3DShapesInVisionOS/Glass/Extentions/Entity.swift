/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension of the entity class, to update materials in real time.
*/

import RealityKit

/// The extension that enables entities to updates its materials.
extension Entity {
    /// Finds all materials in a component, and update them with the custom closure.
    public func updateMaterials(_ update: (inout Material) -> Void) {
        // Call recursive method to all child entities.
        for child in children {
            child.updateMaterials(update)
        }

        // Apply the new values to the component material.
        if var comp = components[ModelComponent.self] {
            comp.materials = comp.materials.map { material in
                var copy = material
                update(&copy)
                return copy
            }
            components.set(comp)
        }
    }
}
