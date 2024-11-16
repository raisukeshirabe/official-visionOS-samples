/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A custom component that controls the robot's functionality.
*/

import RealityKit
import Foundation
import Combine
import Spatial

// Possible robot states.
public enum HeroRobotState: String, Codable {
    case available
    case moving
    case beginReach
    case reaching
    case beginWatering
    case watering
    case stopWatering
    case beginReturnHome
    case disableIKBeforeReturningHome
    case returnHome
    case arrivedHome
}

// Custom action to allow for procedurally setting up the "face-towards-home"
// parameters at runtime.
struct RobotTravelHomeAction: EntityAction {
    var animatedValueType: (any AnimatableData.Type)? { nil }
}

// Custom action to notify when the move-to-home procedure completes.
struct RobotMoveToHomeComplete: EntityAction {
    var animatedValueType: (any AnimatableData.Type)? { nil }
}

// The component stores information about the robot and provides the ability
// to manipulate the internal and visual state of the robot.
public struct HeroRobotComponent: Component, Codable {
    // Defines how long (in seconds) it takes to fully enable or fully disable IK.
    public var ikTotalBlendTime: Float = 0.2
}

@MainActor
public struct HeroRobotRuntimeComponent: Component {

    internal var settingsSource: HeroRobotComponent? = nil

    // Current state of the plant.
    internal var currentState: HeroRobotState = .available

    // Current plant being targeted.
    internal var currentTargetPlantName: String = ""

    // Used to enable or disable IK (1.0 = enable, 0.0 = disable).
    internal var isIKEnabled: Bool = false

    // IK turns on and off over time to avoid popping the arm to or from the reach position.
    // This variable is used to track the amount of time yet to elapse before the IK is fully
    // on or off.
    internal var ikBlendTime: Float = 0.0

    // When true, this component is initialized. When false, it's not initialized.
    private var initialized: Bool = false

    public init() {
    }

    // Returns true if the robot is available for tending a plant.
    public func isAvailable() -> Bool {
        return currentState == .available
    }

    // Sets the robot's current state.
    // Also, optionally assigns the name of the plant the robot is tending.
    public mutating func setState(newState: HeroRobotState, targetPlantName: String? = nil) {
        if !initialized || newState == currentState {
            return
        }

        currentState = newState

        if let name = targetPlantName {
            currentTargetPlantName = name
        }
    }

    // Turns on or off IK based on the 'enable' parameter.
    public mutating func enableIK(enable: Bool) {
        if enable != isIKEnabled {
            ikBlendTime = settingsSource!.ikTotalBlendTime
        }
    }

    // Calculates the position where the robot reaches, given
    // the robot entity and the name of the entity it's reaching for.
    public func calculateReachPosition(from: Entity, toEntityNamed: String) -> SIMD3<Float> {
        var reachPosition = SIMD3<Float>(0.0, 0.0, 0.0)

        if let sceneRoot = from.scene,
           let reachTarget = sceneRoot.findEntity(named: toEntityNamed) {
                reachPosition = reachTarget.position(relativeTo: from)
        }

        return reachPosition
    }

    // Create and assign an IKComponent to the robot entity containing its skeletal data.
    public mutating func initialize(entity: Entity, settingsComponent: HeroRobotComponent) {
        settingsSource = settingsComponent

        // Initialize the robot to use inverse kinematics (IK).
        initializeIKComponent(entity: entity)

        // Make the robot-travel-home custom action to coordinate the robot returning home from tending a plant.
        let robotTravelHomeAction = RobotTravelHomeAction()

        initializeRobotTravelHomeAction(entity: entity, travelHomeAction: robotTravelHomeAction)

        let robotTravelHomeActionResource = try! AnimationResource.makeActionAnimation(for: robotTravelHomeAction, duration: 1.0)

        // Create a custom action that fires when the robot arrives at its home.
        let robotTravelHomeCompleteAction = RobotMoveToHomeComplete()
        let robotTravelHomeCompleteActionResource = try! AnimationResource.makeActionAnimation(for: robotTravelHomeCompleteAction,
                                                                                            duration: 0.1)

        RobotMoveToHomeComplete.subscribe(to: .started) { event in
            if event.playbackController.entity != nil {
                event.playbackController.stop()
            }
        }

        RobotMoveToHomeComplete.subscribe(to: .ended) { event in
            if let robotEntity = event.playbackController.entity {
                // Transition the robot to the .arrivedHome state.
                robotEntity.components[HeroRobotRuntimeComponent.self]?.setState(newState: .arrivedHome)
            }
        }

        // Store actions in an animation library on the robot.
        if var animationLibraryComponent = entity.components[AnimationLibraryComponent.self] {
            // AnimationLibraryComponent exists, so just add the actions to it.
            animationLibraryComponent.animations["RobotReturnToHomeAction"] = robotTravelHomeActionResource
            animationLibraryComponent.animations["RobotTravelHomeCompleteAction"] = robotTravelHomeCompleteActionResource
            entity.components[AnimationLibraryComponent.self] = animationLibraryComponent
        }

        initialized = true
    }

    private mutating func initializeIKComponent(entity: Entity) {
        if let modelComponentEntity = findModelComponentEntity(entity: entity) {
            // Assign an IK component and set up the constraints.
            var skeletonIterator = modelComponentEntity.components[ModelComponent.self]!.mesh.contents.skeletons.makeIterator()
            if let modelSkeleton = skeletonIterator.next() {

                // Start with an empty rig for the given model skeleton.
                var rig = try! IKRig(for: modelSkeleton)

                // Update global rig settings.
                rig.maxIterations = 30
                rig.globalFkWeight = 0.02

                // Joint names for the stationary robot.
                let hipsJointName = "root/hips"
                let chestJointName = "root/hips/spine1/spine2/chest"
                let leftHandJointName = "root/hips/spine1/spine2/chest/L_clavicle/L_arm/L_arm1/L_arm2/L_arm3/L_arm4/L_arm5/L_wrist"

                // Define constraints for the rig.
                rig.constraints = [
                    .parent(named: "hips_constraint",
                            on: hipsJointName,
                            positionWeight: SIMD3(repeating: 90.0),
                            orientationWeight: SIMD3(repeating: 90.0)),
                    .parent(named: "chest_constraint",
                            on: chestJointName,
                            positionWeight: SIMD3(repeating: 120.0),
                            orientationWeight: SIMD3(repeating: 120.0)),
                    .point(named: "left_hand_constraint",
                           on: leftHandJointName,
                           positionWeight: SIMD3(repeating: 10.0))
                ]

                // Add IKComponent with the rig resource.
                let resource = try! IKResource(rig: rig)
                modelComponentEntity.components.set(IKComponent(resource: resource))
            }
        }
    }

    internal mutating func initializeRobotTravelHomeAction(entity: Entity,
                                                           travelHomeAction: RobotTravelHomeAction) {
        // Save the transform of the robot set in RCP as the home location
        let homeTransform = entity.transform

        // Create a closure to handle the robotTravelHomeAction start.
        // This makes sequencing the rotate-to-home animation
        // with the move-to-home and align-at-home actions possible.
        RobotTravelHomeAction.subscribe(to: .started) { event in
            if let robotEntity = event.playbackController.entity,
               let animationLibraryComponent = entity.components[AnimationLibraryComponent.self],
               let robotTravelHomeCompleteActionResource = animationLibraryComponent.animations["RobotTravelHomeCompleteAction"],
               let robotStartWalkAnimationResource = animationLibraryComponent.animations["startWalk"],
               let robotEndWalkAnimationResource = animationLibraryComponent.animations["endWalk"] {

                // Create the animation to rotate the robot towards its home position.
                let (rotateAnimationResource, desiredTransform)
                    = createRotateToHomeAnimation(robotEntity: robotEntity, homeTransform: homeTransform)

                // Create the animations to move the robot home and animate it.
                let (walkAndMoveAnimationGroup, homeTargetTransform)
                    = createWalkAndMoveAnimation(robotEntity: robotEntity,
                                                 homeTransform: homeTransform,
                                                 desiredTransform: desiredTransform,
                                                 startWalkAnimation: robotStartWalkAnimationResource,
                                                 endWalkAnimation: robotEndWalkAnimationResource)

                // Create an animation to align the robot to its home orientation.
                let alignAnimationGroupResource = createAlignToHomeAnimation(robotEntity: robotEntity,
                                                                             homeTargetTransform: homeTargetTransform,
                                                                             homeTransform: homeTransform)

                // Build a sequence of the rotate, move and align animations/actions to play.
                let moveToHomeSequence = try! AnimationResource.sequence(with: [rotateAnimationResource,
                                                                                walkAndMoveAnimationGroup,
                                                                                alignAnimationGroupResource,
                                                                                robotTravelHomeCompleteActionResource])

                // Play the move-to-home sequence.
                _ = robotEntity.playAnimation(moveToHomeSequence)
            }
        }
    }

    internal func findModelComponentEntity(entity: Entity) -> Entity? {
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

@MainActor
internal func createRotateToHomeAnimation(robotEntity: Entity,
                                          homeTransform: Transform) -> (AnimationResource, Transform) {
    // Create the rotation FromToBy animation and sequence it with the move and align animations.
    let desiredRotation = Rotation3D(position: Point3D(robotEntity.position),
                                     target: Point3D(homeTransform.translation),
                                     up: Vector3D(x: 0.0, y: 1.0, z: 0.0))
    let desiredQuaternion = desiredRotation.quaternion
    var desiredTransform = robotEntity.transform
    desiredTransform.rotation = simd_quatf(ix: Float(desiredQuaternion.vector.x),
                                           iy: Float(desiredQuaternion.vector.y),
                                           iz: Float(desiredQuaternion.vector.z),
                                           r: Float(desiredQuaternion.vector.w))

    let rotateAnimation = FromToByAnimation(name: "rotateTowardHome",
                                            to: desiredTransform,
                                            duration: 1.0,
                                            bindTarget: .transform,
                                            fillMode: .forwards)
    let rotateAnimationResource = try! AnimationResource.generate(with: rotateAnimation)

    // Create a PlayAudioAction to sync with the rotate animation.
    let rotateAudioAction = PlayAudioAction(audioResourceName: "rotate_wheel.m4a")
    let rotateAudioAnimationResource = try! AnimationResource.makeActionAnimation(for: rotateAudioAction, duration: 1.0)

    // Group the rotate and rotateAudio animations.
    let rotateAnimationGroupResource = try! AnimationResource.group(with: [rotateAnimationResource, rotateAudioAnimationResource])

    return (rotateAnimationGroupResource, desiredTransform)
}

@MainActor
internal func createWalkAndMoveAnimation(robotEntity: Entity,
                                         homeTransform: Transform,
                                         desiredTransform: Transform,
                                         startWalkAnimation: AnimationResource,
                                         endWalkAnimation: AnimationResource) -> (AnimationResource, Transform) {
    // Sequence the walkStart and walkEnd animations together.
    let robotMoveAnimationSequenceResource = try! AnimationResource.sequence(with: [startWalkAnimation,
                                                                                    endWalkAnimation])
    let moveDuration = robotMoveAnimationSequenceResource.definition.duration

    // Create an animation to move the robot to its home position.
    var homeTargetTransform = homeTransform
    homeTargetTransform.rotation = desiredTransform.rotation
    let moveToHomeAnimation = FromToByAnimation(name: "moveRobotToHome",
                                                from: desiredTransform,
                                                to: homeTargetTransform,
                                                duration: 2.0,
                                                bindTarget: .transform,
                                                fillMode: .forwards,
                                                delay: moveDuration - 2.0)
    let moveToHomeActionResource = try! AnimationResource.generate(with: moveToHomeAnimation)

    // Create a PlayAudioAction to sync with the movement.
    let moveAudioAction = PlayAudioAction(audioResourceName: "walk.m4a")
    let moveAudioAnimationResource = try! AnimationResource.makeActionAnimation(for: moveAudioAction,
                                                                                duration: moveDuration)

    // Group the walk animation with the move animation and move
    // audio animation so they play together.
    let walkAndMoveAnimationGroup = try! AnimationResource.group(
        with: [robotMoveAnimationSequenceResource,
               moveAudioAnimationResource,
               moveToHomeActionResource])
    
    return (walkAndMoveAnimationGroup, homeTargetTransform)
}

@MainActor
internal func createAlignToHomeAnimation(robotEntity: Entity,
                                         homeTargetTransform: Transform,
                                         homeTransform: Transform) -> AnimationResource {
    // Create an animation to align the robot to its home orientation.
    let alignAtHomeAnimation = FromToByAnimation(name: "alignRobotAtHome",
                                                 from: homeTargetTransform,
                                                 to: homeTransform,
                                                 duration: 1.0,
                                                 bindTarget: .transform,
                                                 fillMode: .forwards)
    let alignAtHomeActionResource = try! AnimationResource.generate(with: alignAtHomeAnimation)

    // Create a PlayAudioAction to sync with the align animation.
    let alignAudioAction = PlayAudioAction(audioResourceName: "rotate_wheel.m4a")
    let alignAudioAnimationResource
        = try! AnimationResource.makeActionAnimation(for: alignAudioAction,
                                                     duration: 1.0)

    // Group the align and alignAudio animations.
    let alignAnimationGroupResource
        = try! AnimationResource.group(with: [alignAtHomeActionResource,
                                              alignAudioAnimationResource])
    
    return alignAnimationGroupResource
}

// The HeroRobotSystem manages the coordination of initializing and updating
// the robot.
@MainActor
public class HeroRobotSystem: System {

    // Define a query to return all entities with a HeroRobotComponent.
    private static let query = EntityQuery(where: .has(HeroRobotRuntimeComponent.self))

    private var subscription: Cancellable?

    // Initialize the scene. Use an empty implementation if there isn't any
    // necessary setup.
    public required init(scene: Scene) {
        subscription =
            scene.subscribe(
                to: ComponentEvents.DidAdd.self,
                componentType: HeroRobotComponent.self, { event in
                    self.createRuntimeComponent(entity: event.entity)
                }
            )
    }

    // Iterate through all entities containing a HeroRobotComponent. Process
    // the robot's current state each frame, For more information about
    // processRobotUpdates, see HeroRobotComponentExtension.swift.
    public func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            entity.components[HeroRobotRuntimeComponent.self]!.processRobotUpdates(entity: entity,
                                                                            deltaTime: context.deltaTime)
        }
    }

    // If the entity has a HeroRobotComponent, then add a
    // HeroRobotRuntimeComponent that uses it.
    private func createRuntimeComponent(entity: Entity) {
        if let settingsComponent = entity.components[HeroRobotComponent.self] {

            var runtimeComponent = HeroRobotRuntimeComponent()
            runtimeComponent.initialize(entity: entity, settingsComponent: settingsComponent)

            entity.components.set(runtimeComponent)
        }
    }
}
