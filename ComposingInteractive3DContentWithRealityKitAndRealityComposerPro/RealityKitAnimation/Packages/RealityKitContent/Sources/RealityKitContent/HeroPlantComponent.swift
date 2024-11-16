/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A custom component that simulates each plant that the hero robot visits.
*/

import RealityKit
import Foundation
import Combine

// Possible states of the plant.
public enum PlantState: String, Codable {
    // The plant is in need of water and is wilted.
    case wilted
    // The plant has been watered and appears healthy.
    case healthy
    // The plant is actively wilting and will need water.
    case wilting
    // The plant is visually healing after receiving water.
    case healing
}

// Store information about a plant and provide the ability to manipulate
// the internal and visual state of the plant.
// `HeroPlantComponent` is Codable so it can interface with
// Reality Composer Pro and expose user-friendly parameters
// for the component.
public struct HeroPlantComponent: Component, Codable {

    // Current state of the plant.
    var startingState: PlantState = .wilted

    // Number of seconds it takes for the plant to wilt.
    var totalWiltingTime: Float = 10.0

    // Number of seconds it takes for the plant to heal.
    var totalHealingTime: Float = 10.0

    // Number of seconds before a healthy plant starts to wilt.
    var timeBeforeWilting: Float = 15.0
}

// `HeroPlantRuntimeComponent` contains the
// runtime data and functions necessary to update all aspects
// of a plant that the hero robot can visit.
@MainActor
public struct HeroPlantRuntimeComponent: Component {

    // Reference to a `HeroPlantComponent` which contains the
    // user-tunable settings.
    private var settingsSource: HeroPlantComponent? = nil

    // Current state of the plant.
    var currentState: PlantState = .wilted

    // Seconds left until the plant starts wilting (for .healthy state).
    private var currentTimeUntilWilting: Float = 0.0

    // Seconds left until the plant has fully wilted (for .wilting state).
    private var currentWiltingTime: Float = 0.0

    // Seconds left until the plant has fully healed (for .healing state).
    private var currentHealingTime: Float = 0.0

    // AnimationPlaybackController that's valid when the
    // wilting animation is playing.
    private var wiltingPlaybackController: AnimationPlaybackController? = nil

    // AnimationPlaybackController that's valid when the
    // healing animation is playing.
    private var healingPlaybackController: AnimationPlaybackController? = nil

    public init() {
    }

    // Returns true if the robot can visit the plant.
    public func needsTending() -> Bool {
        return currentState == .wilted
    }

    // Set the current state of the plant.
    public mutating func setState(newState: PlantState) {
        currentState = newState

        guard let settings = settingsSource
        else {
            return
        }

        switch currentState {
        case .wilted:
            currentWiltingTime = 0.0
            currentHealingTime = 0.0
            wiltingPlaybackController = nil

        case .healthy:
            currentWiltingTime = 0.0
            currentHealingTime = 0.0
            currentTimeUntilWilting = settings.timeBeforeWilting
            healingPlaybackController = nil

        case .wilting:
            currentWiltingTime = settings.totalWiltingTime
            currentHealingTime = 0.0

        case .healing:
            currentWiltingTime = 0.0
            currentHealingTime = settings.totalHealingTime
        }
    }

    // Initialize the BlendShapeWeightsComponent for the plant.
    public mutating func initialize(entity: Entity,
                                    settingsComponent: HeroPlantComponent) {
        settingsSource = settingsComponent

        setState(newState: settingsComponent.startingState)

        // Retrieve the entity that has the mesh component from the
        // object hierarchy and get its mesh resource.
        if let modelComponentEntity = findModelComponentEntity(entity: entity) {
            let modelComponent
                = modelComponentEntity.components[ModelComponent.self]!

            // Create the blend shape weights mapping.
            let blendShapeWeightsMapping
                = BlendShapeWeightsMapping(meshResource: modelComponent.mesh)

            // Create the blend shape weights component from the mapping.
            modelComponentEntity.components.set(BlendShapeWeightsComponent(
                weightsMapping: blendShapeWeightsMapping))

            // Initialize the blend shape weights.
            processCurrentStateForBlendShapes(entity: entity, deltaTime: 0.0)
        }
    }

    // Process the plant's current state each frame and perform
    // per-frame, state-specific updates.
    public mutating func processCurrentStateForBlendShapes(entity: Entity,
                                                           deltaTime: TimeInterval) {
        guard let settings = settingsSource
        else {
            return
        }

        guard let blendShapeEntity = findModelComponentEntity(entity: entity)
        else {
            return
        }

        var blendWeightSet = blendShapeEntity.components[BlendShapeWeightsComponent.self]!.weightSet

        processStateTimers(deltaTime: deltaTime)

        switch currentState {
        case .wilted:
            processWiltedState(blendWeightSet: &blendWeightSet)

        case .healthy:
            processHealthyState(blendWeightSet: &blendWeightSet)

        case .wilting:
            processWiltingState(entity: entity, settings: settings)
            return

        case .healing:
            processHealingState(entity: entity, settings: settings)
            return
        }

        // Set the new weights on the blend shape component.
        for blendWeightsIndex in 0..<blendWeightSet.count {
            blendShapeEntity.components[BlendShapeWeightsComponent.self]!.weightSet[blendWeightsIndex].weights
                = blendWeightSet[blendWeightsIndex].weights
        }
    }

    // Update state timers and make state changes.
    private mutating func processStateTimers(deltaTime: TimeInterval) {
        if currentState == .wilting {
            currentWiltingTime -= Float(deltaTime)
            if currentWiltingTime <= 0.0 {
                setState(newState: .wilted)
            }
        } else if currentState == .healing {
            currentHealingTime -= Float(deltaTime)
            if currentHealingTime <= 0.0 {
                setState(newState: .healthy)
            }
        } else if currentState == .healthy {
            currentTimeUntilWilting -= Float(deltaTime)
            if currentTimeUntilWilting <= 0.0 {
                setState(newState: .wilting)
            }
        }
    }

    // Apply blend shape weights directly to make the plant appear wilted.
    private func processWiltedState(blendWeightSet: inout BlendShapeWeightsSet) {
        // Set all the weights for the wilted state.
        for blendWeightsIndex in 0..<blendWeightSet.count {
            for weightIndex in 0..<blendWeightSet[blendWeightsIndex].weights.count {
                if weightIndex == 2 {
                    blendWeightSet[blendWeightsIndex].weights[weightIndex] = 1.0
                } else {
                    blendWeightSet[blendWeightsIndex].weights[weightIndex] = 0.0
                }
            }
        }
    }

    // Apply blend shape weights directly to make the plant appear healthy.
    private func processHealthyState(blendWeightSet: inout BlendShapeWeightsSet) {
        // Set all the weights to 0.0 for the healed state.
        for blendWeightsIndex in 0..<blendWeightSet.count {
            for weightIndex in 0..<blendWeightSet[blendWeightsIndex].weights.count {
                blendWeightSet[blendWeightsIndex].weights[weightIndex] = 0.0
            }
        }
    }

    // Play the healing animation in reverse to make the plant
    // appear to wilt.
    private mutating func processWiltingState(entity: Entity,
                                              settings: HeroPlantComponent) {
        if wiltingPlaybackController == nil {
            // Find the healing animation on the entity.
            // Reverse it to make the wilting animation.
            let availableAnimations = entity.availableAnimations
            if let healingAnimationResource = availableAnimations.first {
                // Create an AnimationView to reverse the animation
                // to make it wilt.
                let wiltingViewDefinition
                    = AnimationView(source: healingAnimationResource.definition,
                                    name: "wiltingView",
                                    fillMode: .backwards,
                                    speed: -1.0)

                // Play the animation.
                if let wiltingAnimationResource = try? AnimationResource.generate(with: wiltingViewDefinition) {
                    wiltingPlaybackController
                        = entity.playAnimation(wiltingAnimationResource)

                    if wiltingPlaybackController != nil &&
                       settings.totalWiltingTime > 0.0 {
                        // Update the animation playback to play
                        // for the total wilting time.
                        let duration
                            = abs(Float(wiltingPlaybackController!.duration))
                        wiltingPlaybackController!.speed
                            *= duration / settings.totalWiltingTime
                    }
                }
            }
        }
    }

    // Play the healing animation to make the plant appear to heal.
    private mutating func processHealingState(entity: Entity,
                                              settings: HeroPlantComponent) {
        if healingPlaybackController == nil {
            // Find the healing animation on the entity.
            let availableAnimations = entity.availableAnimations
            if let healingAnimationResource = availableAnimations.first {
                // Play the animation.
                healingPlaybackController
                    = entity.playAnimation(healingAnimationResource)

                if healingPlaybackController != nil &&
                   settings.totalHealingTime > 0.0 {
                    // Update the animation playback to play
                    // for the total healing time.
                    let duration
                        = abs(Float(healingPlaybackController!.duration))
                    healingPlaybackController!.speed
                        *= duration / settings.totalHealingTime
                }
            }
        }
    }

    // Finds the first Entity from the given entity that has a ModelComponent.
    private func findModelComponentEntity(entity: Entity) -> Entity? {
        if entity.components[ModelComponent.self] != nil {
            return entity
        }

        for child in entity.children {
            if let returnValue = findModelComponentEntity(entity: child) {
                return returnValue
            }
        }

        return nil
    }
}

// Manage the coordination of initializing and updating a hero plant.
@MainActor
public class HeroPlantSystem: System {

    // Define a query to return all entities with a HeroPlantComponent.
    @MainActor
    private static let query = EntityQuery(where: .has(HeroPlantRuntimeComponent.self))

    private var subscription: Cancellable?

    public required init(scene: Scene) {
        subscription =
            scene.subscribe(
                to: ComponentEvents.DidAdd.self,
                componentType: HeroPlantComponent.self, { event in
                    self.createRuntimeComponent(entity: event.entity)
                }
            )
    }

    // Iterates through all entities containing a HeroPlantComponent.
    public func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            entity.components[HeroPlantRuntimeComponent.self]?.processCurrentStateForBlendShapes(
                entity: entity,
                deltaTime: context.deltaTime)
        }
    }

    // If the entity has a HeroPlantComponent, add a
    // HeroPlantRuntimeComponent that uses it.
    private func createRuntimeComponent(entity: Entity) {
        if let heroPlantComponent = entity.components[HeroPlantComponent.self] {

            var runtimeComponent = HeroPlantRuntimeComponent()
            runtimeComponent.initialize(entity: entity, settingsComponent: heroPlantComponent)

            entity.components.set(runtimeComponent)
        }
    }
}
