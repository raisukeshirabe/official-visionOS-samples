/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
This file extends the Hero Robot Runtime Component to provide the process robot
 updates function that processes the robot's current state each frame.
*/

import RealityKit
import Foundation
import Combine
import Spatial

// The hero robot starts in its default 'available' state and transitions through
// additional states as it moves to a plant, waters it, and then returns to its
// starting location. Timeline notifications drive the state transitions
// defined in Reality Composer Pro, as well as internal timing such as when the
// robot's movement to a location finishes.
extension HeroRobotRuntimeComponent {

    // Per-frame processing of the robot's state.
    public mutating func processRobotUpdates(entity: Entity, deltaTime: TimeInterval) {
        var reachPosition: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)

        // Process turning on or off IK values.
        let blendValue = processIKEnableBlending(deltaTime: deltaTime)

        switch currentState {
        case .beginReach: // Set after receiving the reachToPlantReceived notification.
            reachPosition = processBeginReachState(entity: entity)

        case .reaching: // Set while waiting for the notification to water the plant.
            reachPosition = processReachingState(entity: entity)

        case .beginWatering: // Set after receiving the 'startWateringReceived' notification.
            reachPosition = processBeginWateringState(entity: entity)

        case .watering: // Set while waiting for the notification to stop watering the plant.
            reachPosition = processWateringState(entity: entity)

        case .stopWatering: // Set after receiving the 'stopWateringReceived' notification.
            reachPosition = processStopWateringState(entity: entity)

        case .beginReturnHome: // Set after receiving the 'returnHomeReceived' notification.
            reachPosition = processBeginReturnHomeState(entity: entity)

        case .disableIKBeforeReturningHome: // Set when waiting for IK to disable before returning home.
            reachPosition = processDisableIKBeforeReturningHomeState(entity: entity)

        case .arrivedHome: // Set when the robot arrives at the home destination.
            // Nothing to do for now, so transition back to the available state.
            setState(newState: .available, targetPlantName: "")
            return

        default:
            // No work to do for the following cases, so simply return:
            //
            // case .available: Default state, also set when robot arrives
            // back home and is correctly oriented.
            //
            // case .moving: Set from the plant tap when the robot can move
            // to a plant.
            //
            // case .returnHome: Set when the robot starts facing the home
            // direction. Stays in this state while the robot is perfoming its
            // return-to-home action sequence. When the sequence completes the
            // final action causes a transition to .arrivedHome.
            return
        }

        // Update the IK reach target.
        performIKTargetUpdate(entity: entity, reachPosition: reachPosition, blendValue: blendValue)
    }

    private mutating func processIKEnableBlending(deltaTime: TimeInterval) -> Float {
        // Process turning on or off IK values.
        var blendValue: Float = isIKEnabled ? 1.0 : 0.0
        if ikBlendTime > 0.0 {
            ikBlendTime -= Float(deltaTime)
            blendValue = Float(isIKEnabled ? ikBlendTime / settingsSource!.ikTotalBlendTime : (1.0 - ikBlendTime / settingsSource!.ikTotalBlendTime))
            if ikBlendTime <= 0.0 {
                ikBlendTime = 0.0
                isIKEnabled = !isIKEnabled
            }
        }

        return blendValue
    }

    private mutating func processBeginReachState(entity: Entity) -> SIMD3<Float> {
        // Turn on IK.
        enableIK(enable: true)

        // Initialize hand target entity's position.
        let reachTargetName = currentTargetPlantName + "_reach"
        let reachPosition = calculateReachPosition(from: entity, toEntityNamed: reachTargetName)

        // Transition to .reaching state.
        setState(newState: .reaching, targetPlantName: currentTargetPlantName)

        return reachPosition
    }

    private mutating func processReachingState(entity: Entity) -> SIMD3<Float> {
        // Update hand target position.
        let reachTargetName = currentTargetPlantName + "_reach"
        let reachPosition = calculateReachPosition(from: entity, toEntityNamed: reachTargetName)

        // Turn on watering particles.
        if let sceneRoot = entity.scene {
            let particleEmitterName = currentTargetPlantName + "_reach"
            if let particleEmitter = sceneRoot.findEntity(named: particleEmitterName) {
                if particleEmitter.components[ParticleEmitterComponent.self] != nil {
                    particleEmitter.components[ParticleEmitterComponent.self]!.isEmitting = true
                }
            }
        }

        return reachPosition
    }

    private mutating func processBeginWateringState(entity: Entity) -> SIMD3<Float> {
        if let audioLibraryComponent = entity.components[AudioLibraryComponent.self] {
            if let waterSoundResource = audioLibraryComponent.resources["robot_watering.m4a"] {
                // Play the watering sound.
                entity.playAudio(waterSoundResource)
            }
        }

        // Update hand target position.
        let reachTargetName = currentTargetPlantName + "_reach"
        let reachPosition = calculateReachPosition(from: entity, toEntityNamed: reachTargetName)

        if let sceneRoot = entity.scene {
            // Find the plant that's being watered.
            let plantName = currentTargetPlantName
            if let plant = sceneRoot.findEntity(named: plantName) {
                // Set plant state to healing.
                plant.components[HeroPlantRuntimeComponent.self]!.setState(newState: .healing)
            }
        }

        // Transition to .watering state.
        setState(newState: .watering, targetPlantName: currentTargetPlantName)

        return reachPosition
    }

    private mutating func processWateringState(entity: Entity) -> SIMD3<Float> {
        // Update hand target position to extend arm by x units over some amount of time.
        let reachTargetName = currentTargetPlantName + "_reach"
        return calculateReachPosition(from: entity, toEntityNamed: reachTargetName)
    }

    private mutating func processStopWateringState(entity: Entity) -> SIMD3<Float> {
        // Update hand target position.
        let reachTargetName = currentTargetPlantName + "_reach"
        let reachPosition = calculateReachPosition(from: entity, toEntityNamed: reachTargetName)

        // Turn off watering particles.
        if let sceneRoot = entity.scene {
            let particleEmitterName = currentTargetPlantName + "_reach"
            if let particleEmitter = sceneRoot.findEntity(named: particleEmitterName) {
                if particleEmitter.components[ParticleEmitterComponent.self] != nil {
                    particleEmitter.components[ParticleEmitterComponent.self]!.isEmitting = false
                }
            }
        }

        return reachPosition
    }

    private mutating func processBeginReturnHomeState(entity: Entity) -> SIMD3<Float> {
        // Turn off IK.
        enableIK(enable: false)

        // Update hand target position.
        let reachTargetName = currentTargetPlantName + "_reach"
        let reachPosition = calculateReachPosition(from: entity, toEntityNamed: reachTargetName)

        setState(newState: .disableIKBeforeReturningHome)

        return reachPosition
    }

    private mutating func processDisableIKBeforeReturningHomeState(entity: Entity) -> SIMD3<Float> {
        // Update hand target position.
        let reachTargetName = currentTargetPlantName + "_reach"
        let reachPosition = calculateReachPosition(from: entity, toEntityNamed: reachTargetName)

        // Wait until IK has been fully turned off.
        if !isIKEnabled {
            if let animationLibraryComponent = entity.components[AnimationLibraryComponent.self] {
                if let animationResource = animationLibraryComponent.animations["RobotReturnToHomeAction"] {
                    entity.playAnimation(animationResource)

                    // Transition to .returnHome.
                    setState(newState: .returnHome, targetPlantName: "")
                }
            }
        }

        return reachPosition
    }

    private mutating func performIKTargetUpdate(entity: Entity,
                                                reachPosition: SIMD3<Float>,
                                                blendValue: Float) {
        // Update the IK target.
        if let modelComponentEntity = findModelComponentEntity(entity: entity) {
            guard let ikComponent = modelComponentEntity.components[IKComponent.self] else {
                return
            }

            // Set the left hand target position.
            ikComponent.solvers[0].constraints["left_hand_constraint"]?.target.translation = reachPosition
            ikComponent.solvers[0].constraints["left_hand_constraint"]?.animationOverrideWeight.position = blendValue

            // Commit updated values.
            modelComponentEntity.components.set(ikComponent)
        }
    }
}
