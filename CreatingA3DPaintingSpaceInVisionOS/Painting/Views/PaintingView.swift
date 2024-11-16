/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that starts a new painting session and starts hand tracking with drag gestures.
*/

import SwiftUI
import RealityKit
import ARKit

/// A view that contains the `PaintingHandTracking` class and
/// the reality view, which creates a stroke mesh when a person uses the drag gesture.
struct PaintingView: View {
    /// The `PaintingHandTracking` instance for hand tracking.
    var paintingHandTracking = PaintingHandTracking()

    /// The instance of the `PaintingCanvas` class to handle painting operation.
    @State var canvas = PaintingCanvas()

    /// The position of the index finger on the last pinch gesture.
    @State var lastIndexPose: SIMD3<Float>?

    var body: some View {
        RealityView { content in
            /// The root entity from the painting canvas.
            let root = canvas.root

            // Add the canvas to the reality view.
            content.add(root)

            // Attach a closure component to allow hand anchors to update over time.
            root.components.set(ClosureComponent(closure: { deltaTime in
                /// The collection of `HandAnchor` instances.
                var anchors = [HandAnchor]()

                // Add the left hand to the anchors collection.
                if let latestLeftHand = paintingHandTracking.latestLeftHand {
                    anchors.append(latestLeftHand)
                }

                // Add the right hand to the anchors collection.
                if let latestRightHand = paintingHandTracking.latestRightHand {
                    anchors.append(latestRightHand)
                }

                // Loop through each anchor the app detects.
                for anchor in anchors {
                    /// The hand skeleton that associates the anchor.
                    guard let handSkeleton = anchor.handSkeleton else {
                        continue
                    }

                    /// The current position and orientation of the thumb tip.
                    let thumbPos = (anchor.originFromAnchorTransform * handSkeleton.joint(.thumbTip).anchorFromJointTransform).translation()

                    /// The current position and orientation of the index finger tip.
                    let indexPos = (anchor.originFromAnchorTransform * handSkeleton.joint(.indexFingerTip).anchorFromJointTransform).translation()

                    /// The threshold to check if the index and thumb are close.
                    let pinchThreshold: Float = 0.05

                    // Update the last index position if the distance
                    // between the thumb tip and index finger tip is
                    // less than the pinch threshold.
                    if length(thumbPos - indexPos) < pinchThreshold {
                        lastIndexPose = indexPos
                    }
                }
            }))
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                // Enable the gesture to target the drawing canvas.
                .targetedToAnyEntity()
                .onChanged({ _ in
                    if let pos = lastIndexPose {
                        // Add the current position to the canvas.
                        canvas.addPoint(pos)
                    }
                })
                .onEnded({ _ in
                    // End the current stroke when the drag gesture ends.
                    canvas.finishStroke()
                })
        )
        .task {
            // Start hand tracking once the view starts.
            await paintingHandTracking.startTracking()
        }
    }
}

