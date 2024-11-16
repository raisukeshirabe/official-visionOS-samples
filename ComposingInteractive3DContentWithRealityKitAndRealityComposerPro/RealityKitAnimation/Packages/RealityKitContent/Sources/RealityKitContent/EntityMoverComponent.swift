/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A custom component that modifies the position of an entity from frame to frame.
*/

import RealityKit
import Foundation
import Combine

// Store information about how the entity's position changes in the
// local x, y, and z directions.
public struct EntityMoverComponent: Component, Codable {

    // Define how far the position of the entity can move in local x, y, and z
    // directions.
    var movementExtentX: Float = 0.0
    var movementExtentY: Float = 0.0
    var movementExtentZ: Float = 0.0

    // Define how quickly any of the extent values change. 1.0 is normal.
    var movementExtentMultiplierX: Float = 1.0
    var movementExtentMultiplierY: Float = 1.0
    var movementExtentMultiplierZ: Float = 1.0
}

@MainActor
public struct EntityMoverRuntimeComponent: Component {

    private var settingsSource: EntityMoverComponent? = nil

    // The x, y, z extent of movement for the current frame.
    private var currentExtentX: Float = 0.0
    private var currentExtentY: Float = 0.0
    private var currentExtentZ: Float = 0.0

    // The initial x, y, z position of the entity.
    private var initialX: Float = 0.0
    private var initialY: Float = 0.0
    private var initialZ: Float = 0.0

    // The number of seconds the simulation has been running.
    // Use this value to drive the sine wave based movement
    // of the entity.
    private var accumulatedSimTime: Float = 0.0

    public init() {
    }

    // Set the position and initialize the runtime values for the component.
    @MainActor
    public mutating func initialize(entity: Entity,
                                    settingsComponent: EntityMoverComponent) {
        let initialPosition = entity.position

        settingsSource = settingsComponent

        initialX = initialPosition.x
        initialY = initialPosition.y
        initialZ = initialPosition.z
    }

    // Calculate the position of the entity based on the given change in time.
    public mutating func updateMover(entity: Entity,
                                     deltaTime: TimeInterval) {

        guard let settings = settingsSource
        else {
            return
        }

        accumulatedSimTime += Float(deltaTime)

        currentExtentX = sin(accumulatedSimTime *
                             settings.movementExtentMultiplierX) *
                         settings.movementExtentX
        currentExtentY = sin(accumulatedSimTime *
                             settings.movementExtentMultiplierY) *
                         settings.movementExtentY
        currentExtentZ = sin(accumulatedSimTime *
                             settings.movementExtentMultiplierZ) *
                         settings.movementExtentZ

        entity.position = SIMD3<Float>(initialX + currentExtentX,
                                       initialY + currentExtentY,
                                       initialZ + currentExtentZ)
    }
}

// Manage the coordination of initializing and updating
// the `EntityMoverComponent`.
@MainActor
public class EntityMoverSystem: System {

    // Define a query to return all entities with
    // an `EntityMoverRuntimeComponent`.
    private static let runTimeComponentQuery
        = EntityQuery(where: .has(EntityMoverRuntimeComponent.self))

    private var subscription: Cancellable?

    public required init(scene: Scene) {

        // Subscribe to all events in the scene that add an
        // `EntityMoverComponent` and call `createRuntimeComponent`.
        subscription =
            scene.subscribe(
                to: ComponentEvents.DidAdd.self,
                componentType: EntityMoverComponent.self, { event in
                    self.createRuntimeComponent(entity: event.entity)
                }
            )
    }

    // Iterate through all entities containing an `EntityMoverComponent`
    // and update them.
    public func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.runTimeComponentQuery).forEach { entity in
            entity.components[EntityMoverRuntimeComponent.self]?.updateMover(
                entity: entity,
                deltaTime: context.deltaTime)
        }
    }

    // Get the `EntityMoverComponent` on the given entity
    // and add an `EntityMoverRuntimeComponent`.
    private func createRuntimeComponent(entity: Entity) {
        if let entityMoverComponent
            = entity.components[EntityMoverComponent.self] {

            var runtimeComponent = EntityMoverRuntimeComponent()
            runtimeComponent.initialize(entity: entity,
                                        settingsComponent: entityMoverComponent)

            entity.components.set(runtimeComponent)
        }
    }
}
