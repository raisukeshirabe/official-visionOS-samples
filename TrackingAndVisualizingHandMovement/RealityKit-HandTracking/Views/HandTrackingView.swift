/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure with the entity view protocol to generate and update meshes for each hand anchor.
*/

import SwiftUI
import RealityKit
import ARKit

struct HandTrackingView: View {
    /// The ARKit session for hand tracking.
    private let arSession = ARKitSession()

    /// The provider instance for hand tracking.
    private let handTracking = HandTrackingProvider()

    /// The most recent anchor that the provider detects on the left hand.
    @State var latestLeftHand: HandAnchor?

    /// The most recent anchor that the provider detects on the right hand.
    @State var latestRightHand: HandAnchor?

    /// The main body of the view.
    var body: some View {
        RealityView { content in
            content.add(makeHandEntities())
        }
    }

    /// Create and return an entity that contains all hand-tracking entities.
    @MainActor
    func makeHandEntities() -> Entity {
        /// The entity to contain all hand-tracking meshes.
        let root = Entity()

        // Start the ARKit session.
        runSession()

        /// The left hand.
        let leftHand = Hand()

        /// The right hand.
        let rightHand = Hand()

        // Add the left hand to the root entity.
        root.addChild(leftHand.handRoot)

        // Add the right hand to the root entity.
        root.addChild(rightHand.handRoot)

        // Set the `ClosureComponent` to enable the hand entities to update over time.
        root.components.set(ClosureComponent(closure: { deltaTime in
            // Iterate through all of the anchors on the left hand.
            if let leftAnchor = self.latestLeftHand, let leftHandSkeleton = leftAnchor.handSkeleton {
                for (jointName, jointEntity) in leftHand.fingers {
                    /// The current transform of the person's left hand joint.
                    let anchorFromJointTransform = leftHandSkeleton.joint(jointName).anchorFromJointTransform

                    // Update the joint entity to match the transform of the person's left hand joint.
                    jointEntity.setTransformMatrix(leftAnchor.originFromAnchorTransform * anchorFromJointTransform, relativeTo: nil)
                }
            }

            // Iterate through all of the anchors on the right hand.
            if let rightAnchor = self.latestRightHand, let rightHandSkeleton = rightAnchor.handSkeleton {
                for (jointName, jointEntity) in rightHand.fingers {
                    /// The current transform of the person's right hand joint.
                    let anchorFromJointTransform = rightHandSkeleton.joint(jointName).anchorFromJointTransform

                    // Update the joint entity to match the transform of the person's right hand joint.
                    jointEntity.setTransformMatrix(rightAnchor.originFromAnchorTransform * anchorFromJointTransform, relativeTo: nil)
                }
            }
        }))

        return root
    }

    /// Check whether an ARKit session can run and start the hand-tracking provider.
    func runSession() {
        Task {
            do {
                // Attempt to run the ARKit session with the hand-tracking provider.
                try await arSession.run([handTracking])
            } catch let error as ARKitSession.Error {
                print("The App has encountered an error while running providers: \(error.localizedDescription)")
            } catch let error {
                print("The App has encountered an unexpected error: \(error.localizedDescription)")
            }

            // Start to collect each hand-tracking anchor.
            for await anchorUpdate in handTracking.anchorUpdates {
                // Check if the anchor is on the left or right hand.
                switch anchorUpdate.anchor.chirality {
                case .left:
                    self.latestLeftHand = anchorUpdate.anchor
                case .right:
                    self.latestRightHand = anchorUpdate.anchor
                }
            }
        }
    }
}
