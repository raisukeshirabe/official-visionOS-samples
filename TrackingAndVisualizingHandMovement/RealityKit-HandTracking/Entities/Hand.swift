/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure containing all entities attached to hand-tracking anchors.
*/

import RealityKit
import ARKit

/// A structure that contains white spheres on each joint of a hand.
struct Hand {
    /// The hand root to contain all hand-tracking anchor entities.
    var handRoot = Entity()

    /// The entity that associates with the joint name.
    var fingers: [HandSkeleton.JointName: Entity] = [:]

    /// The collection of joints in a hand.
    static let joints: [(HandSkeleton.JointName, Finger, Bone)] = [
        // Define the thumb bones.
        (.thumbKnuckle, .thumb, .knuckle),
        (.thumbIntermediateBase, .thumb, .intermediateBase),
        (.thumbIntermediateTip, .thumb, .intermediateTip),
        (.thumbTip, .thumb, .tip),

        // Define the index-finger bones.
        (.indexFingerMetacarpal, .index, .metacarpal),
        (.indexFingerKnuckle, .index, .knuckle),
        (.indexFingerIntermediateBase, .index, .intermediateBase),
        (.indexFingerIntermediateTip, .index, .intermediateTip),
        (.indexFingerTip, .index, .tip),

        // Define the middle-finger bones.
        (.middleFingerMetacarpal, .middle, .metacarpal),
        (.middleFingerKnuckle, .middle, .knuckle),
        (.middleFingerIntermediateBase, .middle, .intermediateBase),
        (.middleFingerIntermediateTip, .middle, .intermediateTip),
        (.middleFingerTip, .middle, .tip),

        // Define the ring-finger bones.
        (.ringFingerMetacarpal, .ring, .metacarpal),
        (.ringFingerKnuckle, .ring, .knuckle),
        (.ringFingerIntermediateBase, .ring, .intermediateBase),
        (.ringFingerIntermediateTip, .ring, .intermediateBase),
        (.ringFingerTip, .ring, .tip),

        // Define the little-finger bones.
        (.littleFingerMetacarpal, .little, .metacarpal),
        (.littleFingerKnuckle, .little, .knuckle),
        (.littleFingerIntermediateBase, .little, .intermediateBase),
        (.littleFingerIntermediateTip, .little, .intermediateTip),
        (.littleFingerTip, .little, .tip),

        // Define wrist and arm bones.
        (.forearmWrist, .forearm, .wrist),
        (.forearmArm, .forearm, .arm)
    ]

    init() {
        /// The size of the sphere mesh.
        let radius: Float = 0.01

        /// The material to apply to the sphere entity.
        let material = SimpleMaterial(color: .white, isMetallic: false)

        // For each joint, create a sphere and attach it to the finger.
        for bone in Self.joints {
            /// The model entity representation of a hand anchor.
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: radius),
                materials: [material]
            )

            // Add the sphere to the `handRoot` entity.
            handRoot.addChild(sphere)

            // Attach the sphere to the finger.
            fingers[bone.0] = sphere
        }
    }
}
