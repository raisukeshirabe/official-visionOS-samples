/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that creates a custom gesture, enables scene reconstruction, and creates a chair model that reacts to the gesture.
*/

import SwiftUI
import RealityKit
import ARKit

/// A view that creates a custom gesture, enables scene reconstruction,
/// and creates a chair model that reacts to the custom gesture.
struct WorldOcclusionView: View {
    /// The initial position of the model.
    @State var initialPosition: SIMD3<Float>? = nil
    
    /// The gesture that adjusts the postion of the entities that contain `TargetModelComponent`.
    var translationGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged({ value in
                /// The entity that the drag gesture targets.
                let targetEntity = value.entity

                // Set `initialPosition` to the position of the entity if it is nil.
                if initialPosition == nil {
                    initialPosition = targetEntity.position
                }

                // Convert the movement from the SwiftUI coordinate space to the reality view coordinate space.
                let movement = value.convert(value.translation3D, from: .global, to: .scene)

                // Apply the entity position to match the drag gesture,
                // and set the movement to stay at the ground level.
                targetEntity.position = (initialPosition ?? .zero) + movement.grounded
            })
            .onEnded({ _ in
                // Reset the `initialPosition` back to `nil` after the gesture ends.
                initialPosition = nil
            })
    }

    /// Initiates the ARKit session and adds child entities of anchors with occlusion materials to `meshAnchors`.
    func runSession(_ meshAnchors: Entity) {
        /// The ARKit session instance for scene reconstruction.
        let arSession = ARKitSession()

        /// The provider instance for scene reconstruction.
        let sceneReconstruction = SceneReconstructionProvider()

        Task {
            /// The generator to use to replace the mesh on anchors.
            let generator = MeshAnchorGenerator(root: meshAnchors)

            // Check if the device can support `SceneReconstructionProvider`.
            guard SceneReconstructionProvider.isSupported else {
                print("SceneReconstructionProvider is not supported on this device.")
                return
            }

            do {
                // Start the ARKit session to run the `SceneReconstructionProvider`.
                try await arSession.run([sceneReconstruction])
            } catch let error as ARKitSession.Error {
                // Handle any ARKit session errors.
                print("Encountered an error while running providers: \(error.localizedDescription)")
            } catch let error {
                // Handle other unexpected errors.
                print("Encountered an unexpected error: \(error.localizedDescription)")
            }

            // Run the generator after the ARKit session runs successfully.
            await generator.run(sceneReconstruction)
        }
    }

    var body: some View {
        RealityView { content in
            /// The entity to hold anchors with occlusion materials.
            let meshAnchors = Entity()

            // Run the ARKit session.
            runSession(meshAnchors)

            // Add the root to the reality view.
            content.add(meshAnchors)
            
            // Load the chair model from the filename asynchronously.
            let fileName: String = "chair_swan"
            guard let chair = try? await ModelEntity(named: fileName) else {
                assertionFailure("Failed to load model: \(fileName)")
                return
            }

            // Generate collision shapes to the chair for proper occlusion.
            chair.generateCollisionShapes(recursive: true)
            
            // Enable inputs to detect the hand gestures.
            chair.components.set(InputTargetComponent())

            // Add the chair entity to the `RealityView`.
            content.add(chair)
        }
        // Set the `translationGesture` to the view.
        .gesture(translationGesture)
    }
}
