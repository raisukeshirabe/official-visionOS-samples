/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system and component to update an entity's transform in real time.
*/

import SwiftUI
import RealityKit

/// A component to attach to an entity that updates over time.
struct ClosureComponent: Component {
    /// The closure that takes the time interval since the last update.
    let closure: (TimeInterval) -> Void

    init (closure: @escaping (TimeInterval) -> Void) {
        self.closure = closure
        ClosureSystem.registerSystem()
    }
}

/// A system to update the scene over the duration of the app's runtime.
struct ClosureSystem: System {
    /// The query to check if the entity has the `ClosureComponent`.
    static let query = EntityQuery(where: .has(ClosureComponent.self))

    init(scene: RealityKit.Scene) {}
    
    /// Update entities with `ClosureComponent` at each render frame.
    func update(context: SceneUpdateContext) {
        // Iterate over all entities in the query.
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            // Execute the closure, and pass the delta time since the last update.
            guard let comp = entity.components[ClosureComponent.self] else { continue }
            comp.closure(context.deltaTime)
        }
    }
}
