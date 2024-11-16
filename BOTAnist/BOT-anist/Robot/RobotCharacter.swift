/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that represents the robot.
*/

import RealityKit
import SwiftUI
import Foundation
import Spatial
import Combine
import BOTanistAssets

/// An object that contains the characteristics of the robot during exploration mode.
@MainActor
@Observable
class RobotCharacter {
    /// The parent of all entities that make up the robot.
    var characterParent = Entity()
    /// The parent of the models for each robot part.
    var characterModel = Entity()
    var head: Entity
    var body: Entity
    var backpack: Entity
    /// The type of the robot body.
    var bodyType: BodyType = .bipedal
    
    /// The vector that represents the direction of the robot's movement.
    var movementVector: SIMD3<Float> = .zero
    /// A multiplier you use to calculate the movement speed for the robot.
    var baseSpeed: Float = 0.165
    /// A multiplier you use to calculate the movement speed for the robot.
    ///
    /// When a person resizes the volume, this value updates to keep the robot's speed consistent.
    var speedScale: Float = 1
    /// The number of plants the robot has planted.
    var plantsFound: Int = 0
    var collisionCapsuleRadius: Float = 0.2
    var collisionCapsuleHeight: Float = 2
    
    /// The robot's current animation state.
    var animationState: AnimationState = .idle
    var subscriptions = [any Cancellable]()
    var appState: AppState
    
    #if os(visionOS)
    /// The direction the robot turns to face front after the idle timer expires.
    var idleViewpoint: SquareAzimuth = .front
    #endif
    
    /// The amount of idle time before the robot turns to face the direction in the idle Viewpoint.
    let idleTimeout: Float = 2.0
    /// The amount of time the robot has been idle.
    var idleTimer: Float = 0.0
    
    /// A Boolean value that indicates whether the robot is rotating.
    var isRotatingToFaceFront = false
    /// A Boolean value that indicates whether the person using the app has changed the orientation they're viewing the volume from.
    var hasChangedOrientationSinceLastWave = false
    
    /// The scale factor of the 3D models that comprise the robot.
    private var modelScale: Float = 0.065

    let rotationDuration = 0.5
    
    var animationControllers = [AnimationState: AnimationPlaybackController]()
    
    init(head: Entity, body: Entity, backpack: Entity, appState: AppState, headOffset: SIMD3<Float>? = nil, backpackOffset: SIMD3<Float>? = nil) {
        self.head = head
        self.body = body
        self.backpack = backpack
        self.appState = appState
        
        self.body.removeFromParent()
        self.head.removeFromParent()
        self.backpack.removeFromParent()
        
        guard let skeleton = body.findEntity(named: "rig_grp") as? ModelEntity else {
            fatalError("Didn't find expected rig_grp entity as descendent of rigged body.")
        }
        
        guard let skeletonClone = self.body.findEntity(named: "rig_grp") as? ModelEntity else {
            fatalError("Didn't find expected rig_grp entity as descendent of rigged body.")
        }
        
        let headJointIndices = getJointHierarchy(skeleton, for: "head")
        let backpackJointIndices = getJointHierarchy(skeleton, for: "backpack")
        
        // The backpack and head models are located at the pin location. To rotate them in place, which is how joints operate,
        // joint pinning system translates by the offset, rotates, and then translates back to original position.
        let headPin = skeleton.pins.set(named: "headPin", skeletalJointName: "head")
        let backpackPin = skeleton.pins.set(named: "backbackPin", skeletalJointName: "backpack")
        guard var headOffset = headOffset ?? headPin.position,
              var backpackOffset = backpackOffset ?? backpackPin.position else {
            fatalError("Didn't find expected joint for head or backpack.")
        }
        headOffset *= -1
        backpackOffset *= -1
        skeletonClone.jointPinComponent = JointPinComponent(headEntity: self.head,
                                                            headJointIndices: headJointIndices,
                                                            headOffset: Transform(translation: headOffset).matrix,
                                                            backpackEntity: self.backpack,
                                                            backpackJointIndices: backpackJointIndices,
                                                            backpackOffset: Transform(translation: backpackOffset).matrix,
                                                            bodyEntity: self.body)
        
        characterParent.components.set(CharacterControllerComponent(radius: collisionCapsuleRadius,
                                                                    height: collisionCapsuleHeight,
                                                                    slopeLimit: 0,
                                                                    stepLimit: 0))
        characterParent.setPosition([0, collisionCapsuleHeight / 2 * modelScale, 0], relativeTo: nil)
        characterModel.addChild(self.head)
        characterModel.addChild(self.body)
        characterModel.addChild(self.backpack)
        characterParent.addChild(characterModel)
        characterModel.setPosition([0, -collisionCapsuleHeight / 2, 0], relativeTo: characterParent)
        
        characterParent.scale = SIMD3<Float>(repeating: modelScale)
        animationState.registerHandler { @MainActor state in
            self.playAnimation(state)
        }
    }
    
    /// Plays the robot animation for the given animation state.
    func playAnimation(_ animState: AnimationState) {
        guard let anim = body.animationLibraryComponent?.animations[animState.rawValue] else {
            fatalError("Didn't find requested animation in library.")
        }
        if let rigGroup = body.findEntity(named: "rig_grp") {
            switch animState.loopingBehavior {
            case .infinite:
                // Pause automatic state transitions while rotating to face front.
                if !isRotatingToFaceFront {
                    let playback = rigGroup.playAnimation(anim.repeat(), separateAnimatedValue: true, startsPaused: false)
                    animationControllers[animState] = playback
                }
            case .finite(let times):
                let playback = rigGroup.playAnimation(anim.repeat(count: times), separateAnimatedValue: true, startsPaused: false)
                animationControllers[animState] = playback
                
                let entitySubscription = rigGroup.scene?.publisher(for: AnimationEvents.PlaybackCompleted.self, on: rigGroup)
                    .sink { [weak self] _ in
                        guard let self = self else { fatalError("Could not get reference to 'self' in closure.") }
                        let nextState = self.animationState.nextState
                        if self.animationState != self.animationState.nextState {
                            self.animationState.transition(to: nextState)
                        } else {
                            if self.animationState != .idle {
                                self.idleTimer = 0
                            }
                        }
                    }
                if let subscription = entitySubscription {
                    subscriptions.append(subscription)
                }
            }
        }
    }
    
    func stopAllAnimations() {
        for animState in AnimationState.allCases {
            let controller = animationControllers[animState]
            controller?.stop()
            animationControllers[animState] = nil
        }
        body.stopAllAnimations(recursive: true)
    }
    
    private func getJointHierarchy(_ skeleton: ModelEntity, for jointName: String) -> [Int] {
        guard let jointIndex = skeleton.getJointIndex(suffix: jointName) else { fatalError("Unable to retrieve joint named \(jointName).") }
        let jointNames = skeleton.jointNames
        let jointPath = jointNames[jointIndex]
        var components = jointPath.components(separatedBy: "/")
        var indices: [Int] = []
        while !components.isEmpty {
            let path = components.joined(separator: "/")
            indices.append(jointNames.firstIndex(of: path)!)
            components.removeLast()
        }
        
        var boneList = [String]()
        for index in indices {
            let boneName = skeleton.jointNames[index]
            boneList.append(boneName)
        }
        
        return indices
    }
}
