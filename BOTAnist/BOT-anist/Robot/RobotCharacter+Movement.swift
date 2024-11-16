/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class extension containing movement-related functions.
*/

import BOTanistAssets
import Combine
import Foundation
import RealityKit
import Spatial
import SwiftUI

extension RobotCharacter {
    /// Handles the movement of the robot every time RealityKit updates the scene.
    func handleMovement(deltaTime: Float) {
        guard ![.celebrate, .wave].contains(animationState) else { return }
        if movementVector != .zero {
            handleNonZeroMovement(deltaTime: deltaTime)
        } else {
            handleZeroMovement(deltaTime: deltaTime)
        }
    }
    
    /// Handles the behavior of the robot if its movement vector is non-zero.
    private func handleNonZeroMovement(deltaTime: Float) {
        // If the player is moving the robot, reset the idle timer.
        idleTimer = 0
        
        // Normalizing the movement vector makes sure diagonal movement doesn't have a higher speed
        // than movement in the cardinal directions.
        let normalizedMovement = movementVector / max(100, length(movementVector))
        var speed = baseSpeed
        if animationState == .walkEnd {
            speed = 0.001
        }

        // Move the robot in the direction of the movement vector with scaling applied to account for volume size changes.
        // In the event of a collision, check if the collision object is a plant that hasn't been interacted with.
        // If it is a plant, trigger the plant's grow animation.
        characterParent.moveCharacter(by: normalizedMovement * speed * speedScale * deltaTime, deltaTime: deltaTime, relativeTo: nil) { collision in
            if var plantComponent = collision.hitEntity.plantComponent {
                if plantComponent.interactedWith == false {
                    plantComponent.interactedWith = true
                    collision.hitEntity.components.set(plantComponent)
                    self.plantsFound += 1
                    if let growAnimation = PlantAnimationProvider.shared.growAnimations[plantComponent.plantType] {
                        collision.hitEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { entity, component in
                            let playbackController = entity.playAnimation(growAnimation)
                            PlantAnimationProvider.shared.currentGrowAnimations[plantComponent.plantType] = playbackController
                        }
                    }
                }
            }
            if self.plantsFound == self.appState.totalPlants && self.animationState != .celebrate {
                self.animationState.transition(to: .celebrate)
            }
        }
        // Make sure the robot's facing the direction of the movement.
        characterModel.look(at: characterModel.position(relativeTo: characterParent) - normalizedMovement,
                            from: characterModel.position(relativeTo: characterParent), relativeTo: characterParent)
    }
    
    /// Handles the behavior of the robot if its movement vector is zero.
    private func handleZeroMovement (deltaTime: Float) {
        idleTimer += deltaTime
        guard idleTimer > idleTimeout && animationState == .idle && !isRotatingToFaceFront else { return }
        
        guard hasChangedOrientationSinceLastWave else {
            return
        }

#if os(visionOS)
        // Generate a rotation animation for the model parent to face the given viewpoint.
        guard let rotateAnimation = characterModel.getRotationAnimation(toFace: self.idleViewpoint,
                                                                        duration: rotationDuration) else { fatalError() }
        hasChangedOrientationSinceLastWave = false
        isRotatingToFaceFront = true
        self.animationState.transition(to: .wave)
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(rotationDuration / 2.0))
            characterModel.playAnimation(rotateAnimation)
            try? await Task.sleep(for: .seconds(rotationDuration / 2.0))
            let angle = self.idleViewpoint.orientation.angle.radians
            let finalOrientation = simd_quatf(angle: Float(angle), axis: SIMD3<Float>(x: 0, y: 1, z: 0))
            self.characterModel.orientation = finalOrientation
            self.idleTimer = 0
            self.isRotatingToFaceFront = false
        }
#endif
    }
}
