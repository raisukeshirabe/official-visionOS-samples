/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A custom component that controls the reach and look-at behavior for
 a stationary robot.
*/

import RealityKit
import Foundation
import Combine
import Spatial

// StationaryRobotComponent is Codable so it can interface with
// Reality Composer Pro and expose user-friendly parameters
// for the component.
public struct StationaryRobotComponent: Component, Codable {

    // Offset the hand IK target from the butterfly by this amount.
    public var ikOffset: SIMD3<Float> = [0, -0.07, 0]
}

// StationaryRobotRuntimeComponent is the component that contains the
// runtime data and functions necessary to update all aspects
// of the stationary robot's IK and SkeletalPose usage. It controls
// the robot's ability to reach for and look at the butterfly.
@MainActor
public struct StationaryRobotRuntimeComponent: Component {

    private var settingsSource: StationaryRobotComponent? = nil

    private let chestJointName = "root/hips/spine01/spine02/chest"
    private let neckJointName = "root/hips/spine01/spine02/chest/neck"
    private var neckJointIndex: Int = 0
    private var neckForward: SIMD3<Float> = [0, 0, 0]

    // Values to introduce some latency into the robot's reach position.
    // 'latencyDelay' defines (in seconds) how delayed the robot's reach
    // position is relative to the true position of the reach object.
    var previousReachPos: SIMD3<Float>?
    var currentReachPos: SIMD3<Float>?
    var latencyCountdown: Float = 0
    let latencyDelay: Float = 0.333

    public init() {
    }

    // Initialize the IKComponent and the SkeletalPosesComponent for the robot.
    public mutating func initialize(entity: Entity,
                                    settingsComponent: StationaryRobotComponent) {
        settingsSource = settingsComponent

        if let modelComponentEntity = findModelComponentEntity(entity: entity) {
            // Assign an IK component here and set up the constraints.
            var skeletonIterator = modelComponentEntity.components[ModelComponent.self]!.mesh.contents.skeletons.makeIterator()
            if let modelSkeleton = skeletonIterator.next() {

                // Start with an empty rig for the given model skeleton.
                var rig = try! IKRig(for: modelSkeleton)

                // Update global rig settings.
                rig.maxIterations = 30

                rig.globalFkWeight = 0.02

                // Define the paths to the joints for the stationary robot.
                let hipsJointName = "root/hips"
                let chestJointName = "root/hips/spine01/spine02/chest"
                let leftHandJointName = "root/hips/spine01/spine02/chest/L_clavicle/L_arm/L_arm1/L_arm2/L_arm3/L_arm4/L_wrist"

                // Define constraints for the rig.
                rig.constraints = [
                    .parent(named: "hips_constraint",
                            on: hipsJointName,
                            positionWeight: SIMD3(repeating: 20.0),
                            orientationWeight: SIMD3(repeating: 9.0)),
                    .parent(named: "chest_constraint",
                            on: chestJointName,
                            positionWeight: SIMD3(repeating: 12.0),
                            orientationWeight: SIMD3(repeating: 12.0)),
                    .point(named: "left_hand_constraint",
                           on: leftHandJointName,
                           positionWeight: SIMD3(repeating: 1.0))
                ]

                // Make a resource containing the rig.
                let resource = try! IKResource(rig: rig)

                // Add IKComponent with the given resource.
                modelComponentEntity.components.set(IKComponent(resource: resource))

                // Calculate the 'forward' direction for the neck in model space.
                let neckPin = modelComponentEntity.pins.set(named: neckJointName, skeletalJointName: neckJointName)
                if let origNeckRotation = neckPin.orientation {
                    neckForward = origNeckRotation.act(SIMD3<Float>(0, 0, 1))
                }

                // Look up and cache the index of the neck bone.
                if let poseComponent = modelComponentEntity.components[SkeletalPosesComponent.self] {
                    neckJointIndex = poseComponent.poses.default!.jointNames.firstIndex(of: neckJointName)!
                }
            }
        }
    }

    // Update the robot's IK (reaching) and SkeletalPoses (look-at) values.
    public mutating func processRobotUpdates(entity: Entity,
                                             deltaTime: TimeInterval) {
        if let sceneRoot = entity.scene {
            if let butterflyEntity = sceneRoot.findEntity(named: "butterfly_fly_cycle") {

                // Get the position of the butterfly in the robot entity's local space.
                let butterflyPositionModelSpace = butterflyEntity.position(relativeTo: entity)

                if let modelComponentEntity = findModelComponentEntity(entity: entity) {
                    // Update the latency countdown time.
                    var reachPos = butterflyPositionModelSpace + settingsSource!.ikOffset

                    if latencyDelay > 0.0 {
                        // Compute the robot's reach position to be at a position
                        // close to where the reach object was 'latencyDelay'
                        // seconds before.
                        latencyCountdown -= Float(deltaTime)

                        if latencyCountdown <= 0 {
                            latencyCountdown = latencyDelay
                            if previousReachPos == nil {
                                previousReachPos = reachPos
                            } else if currentReachPos == nil {
                                currentReachPos = reachPos
                            } else {
                                previousReachPos = currentReachPos
                                currentReachPos = reachPos
                            }
                        }

                        reachPos = previousReachPos!
                        if previousReachPos != nil && currentReachPos != nil {
                            // Compute the new reach position at a point between previous and current
                            // based on the latencyCountdown timer.
                            let interpolationValue = 1.0 - Float(latencyCountdown / latencyDelay)
                            reachPos = previousReachPos! + ((currentReachPos! - previousReachPos!) * interpolationValue)
                        }
                    }

                    // Update the arm to point at the butterfly.
                    updateHandIK(entity: modelComponentEntity, ikTarget: reachPos)

                    // Update the head to look at the butterfly.
                    updateHeadLookAt(entity: modelComponentEntity, lookAtTarget: butterflyPositionModelSpace)
                }
            }
        }
    }

    // Update the target position for the robot's left hand reach.
    private mutating func updateHandIK(entity: Entity,
                                       ikTarget: SIMD3<Float>) {
        // Update the IK target.
        if let ikComponent = entity.components[IKComponent.self] {

            // Set the left hand target position.
            ikComponent.solvers[0].constraints["left_hand_constraint"]!.target.translation
                = ikTarget
            ikComponent.solvers[0].constraints["left_hand_constraint"]!.animationOverrideWeight.position
                = 1.0

            // Commit updated values.
            entity.components.set(ikComponent)
        }
    }

    // Rotate the neck bone of the entity to look at the given target position.
    // Assume that the target is in the entity's model space.
    private func updateHeadLookAt(entity: Entity,
                                  lookAtTarget: SIMD3<Float>) {

        // Get the position of the neck bone in model space.
        let neckPin = entity.pins.set(named: neckJointName, skeletalJointName: neckJointName)
        let neckPositionModelSpace = neckPin.position!

        let neckToTarget = simd_normalize(lookAtTarget - neckPositionModelSpace)

        // Calculate the quaternion to rotate the neck from facing forward to facing the target.
        let lookAtRotationModelSpace = calcRotation(fromDirection: neckForward, toDirection: neckToTarget)

        // Find the current "up" direction of the head.
        let headUpDirLocalSpace = SIMD3<Float>(1, 0, 0)
        let headUpDirModelSpace = lookAtRotationModelSpace.act(headUpDirLocalSpace)

        // Calculate the rotation to keep the head upright.
        let uprightRotationModelSpace = calcRotationAboutAxis(fromDirection: headUpDirModelSpace,
                                                              toDirection: [0, 1, 0],
                                                              limitedToAxis: neckToTarget)

        // Combine the lookat and upright rotations.
        let neckRotationModelSpace = uprightRotationModelSpace * lookAtRotationModelSpace

        // Convert the neck rotation in model space into the local space of
        // its parent bone, the chest.

        // Get the model space rotation of the chest bone.
        let chestPin = entity.pins.set(named: chestJointName, skeletalJointName: chestJointName)
        let chestRotationModelSpace = chestPin.orientation!

        // Convert the neck rotation into the coordinate space of the chest.
        let neckRotationLocalSpace = chestRotationModelSpace.inverse * neckRotationModelSpace

        entity.components[SkeletalPosesComponent.self]!.poses.default!.jointTransforms[neckJointIndex].rotation
            = neckRotationLocalSpace
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

    // Calculate the rotation to transform one direction vector to point in the same
    // direction as another.  Both input vectors must be normalized.
    private func calcRotation(fromDirection: SIMD3<Float>,
                              toDirection: SIMD3<Float>) -> simd_quatf {

        // Use the cross product to find the axis of rotation.
        let axis = simd_normalize(simd_cross(fromDirection, toDirection))

        // Use the dot product to find the cosine of the angle between them.
        let cosAngle = simd_dot(fromDirection, toDirection)

        // Take the arccosine to get the angle in radians.  Make sure the
        // value passed to acos is between -1 and 1 to avoid errors.
        let angle = acos( min( max(cosAngle, -1), 1) )

        // Return a quaternion using the calculated axis and angle.
        return simd_quatf(angle: angle, axis: axis)
    }

    // Same as calcRotation, but limits the rotation to the given axis.
    private func calcRotationAboutAxis(fromDirection: SIMD3<Float>,
                                       toDirection: SIMD3<Float>,
                                       limitedToAxis: SIMD3<Float>) -> simd_quatf {
        let perpendicularFrom = simd_normalize( simd_cross(fromDirection, limitedToAxis) )
        let perpendicularTo = simd_normalize( simd_cross(toDirection, limitedToAxis) )
        return calcRotation(fromDirection: perpendicularFrom, toDirection: perpendicularTo)
    }
}

// The StationaryRobotSystemcoordination manages the initializing and
// updating of the robot.
@MainActor
public class StationaryRobotSystem: System {

    // Define a query to return all entities with a MyComponent.
    @MainActor
    private static let query = EntityQuery(where: .has(StationaryRobotRuntimeComponent.self))

    private var subscription: Cancellable?

    public required init(scene: Scene) {
        subscription =
            scene.subscribe(
                to: ComponentEvents.DidAdd.self,
                componentType: StationaryRobotComponent.self, { event in
                    self.createRuntimeComponent(entity: event.entity)
                }
            )
    }

    // Iterate through all entities containing a StationaryRobotComponent.
    public func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            entity.components[StationaryRobotRuntimeComponent.self]?.processRobotUpdates(entity: entity,
                                                                                  deltaTime: context.deltaTime)
        }
    }
    
    // If the entity has a StationaryRobotComponent, then add a
    // StationaryRobotRuntimeComponent that uses it.
    private func createRuntimeComponent(entity: Entity) {
        if let settingsComponent = entity.components[StationaryRobotComponent.self] {

            var runtimeComponent = StationaryRobotRuntimeComponent()
            runtimeComponent.initialize(entity: entity, settingsComponent: settingsComponent)

            entity.components.set(runtimeComponent)
        }
    }
}
