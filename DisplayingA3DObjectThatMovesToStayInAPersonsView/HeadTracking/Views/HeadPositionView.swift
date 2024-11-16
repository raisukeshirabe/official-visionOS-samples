/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A RealityKit view that creates an entity that follows the device transform.
*/

import SwiftUI
import RealityKit

/// An immersive view that creates a small sphere that smoothly translates to always be in front of the device.
struct HeadPositionView: View {
    /// The tracker that contains the logic to handle real-time transformations from the device.
    @StateObject var headTracker = HeadPositionTracker()
    
    var body: some View {
        RealityView(make: { content in
            /// The entity representation of the world origin.
            let root = Entity()
            
            /// The size of the floating sphere.
            let radius: Float = 0.02
            
            /// The material for the floating sphere.
            let material = SimpleMaterial(color: .cyan, isMetallic: false)
            
            /// The sphere mesh entity.
            let floatingSphere = ModelEntity(
                mesh: .generateSphere(radius: radius),
                materials: [material]
            )
            
            // Add the floating sphere to the root entity.
            root.addChild(floatingSphere)
            
            /// The distance that the content extends out from the device.
            let distance: Float = 1.0
            
            // Set the closure component to the root, enabling the sphere to update over time.
            root.components.set(ClosureComponent(closure: { deltaTime in
                /// The current position of the device.
                guard let currentTransform = headTracker.originFromDeviceTransform() else {
                    return
                }

                /// The target position in front of the device.
                let targetPosition = currentTransform.translation() - distance * currentTransform.forward()

                /// The interpolation ratio for smooth movement.
                let ratio = Float(pow(0.96, deltaTime / (16 * 1E-3)))

                /// The new position of the floating sphere.
                let newPosition = ratio * floatingSphere.position(relativeTo: nil) + (1 - ratio) * targetPosition

                // Update the position of the floating sphere.
                floatingSphere.setPosition(newPosition, relativeTo: nil)
            }))

            // Add the root entity to the `RealityView`.
            content.add(root)
        }, update: { _ in })
    }
}

