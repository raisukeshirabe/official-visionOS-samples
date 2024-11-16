/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that enables scene reconstruction by applying unlit materials to real-world objects.
*/

import SwiftUI
import RealityKit
import ARKit

/// A view that enables scene reconstruction with `ARKitSession` and `SceneReconstructionProvider` by applying unlit materials to real-world objects.
struct SceneReconstructionView: View {
    var body: some View {
        RealityView { content in
            /// The root entity.
            let root = Entity()

            /// The `ARKitSession` instance for scene reconstruction.
            let arSession = ARKitSession()

            /// The provider instance for scene reconstruction.
            let sceneReconstruction = SceneReconstructionProvider()

            Task {
                /// The generator to store the root with unlit materials.
                let generator = MeshAnchorGenerator(root: root)

                // Check if the device supports scene reconstruction.
                guard SceneReconstructionProvider.isSupported else {
                    print("SceneReconstructionProvider is not supported on this device.")
                    return
                }

                do {
                    // Start the `ARKitSession` and run the `SceneReconstructionProvider`.
                    try await arSession.run([sceneReconstruction])
                } catch let error as ARKitSession.Error {
                    // Handle any `ARKitSession` errors.
                    print("Encountered an error while running providers: \(error.localizedDescription)")
                } catch let error {
                    // Handle other errors.
                    print("Encountered an unexpected error: \(error.localizedDescription)")
                }

                // Start the generator if the session runs successfully.
                await generator.run(sceneReconstruction)
            }

            // Add the root entity to the `RealityView`.
            content.add(root)
        }
    }
}
