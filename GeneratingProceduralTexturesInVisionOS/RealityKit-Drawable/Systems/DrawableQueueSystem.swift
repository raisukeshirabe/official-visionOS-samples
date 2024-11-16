/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The system that updates entities that contain drawable queue components over time.
*/

import RealityKit

/// The system that updates over time for entities with a `DrawableQueueComponent`.
struct DrawableQueueSystem: System {
    /// The query to check whether the entity has `DrawableQueueComponent`.
    static let query = EntityQuery(where: .has(DrawableQueueComponent.self))
    
    init(scene: RealityKit.Scene) { }
    
    /// Update the results to attach delta time to the component.
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            if var comp = entity.components[DrawableQueueComponent.self] {
                // Run the update function with `deltaTime`.
                comp.update(deltaTime: context.deltaTime)
                
                // Reassign the component back to the entity.
                entity.components[DrawableQueueComponent.self] = comp
            }
        }
    }
}
