/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that holds the 3D content for the app's immersive space.
*/

import ARKit
import SwiftUI
import RealityKit

let cubeMeshInteractionID = "CubeMeshInteraction"

/// A view that lets people place cubes in their surroundings based on the scene reconstruction mesh.
///
/// A tap on any of the meshes drops a cube above it.
struct CubeMeshInteraction: View {
    @Environment(EntityModel.self) var model
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    
    @State private var timer: Timer?
    
    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .task {
            do {
                if model.dataProvidersAreSupported && model.isReadyToRun {
                    try await model.session.run([model.sceneReconstruction, model.handTracking])
                } else {
                    await dismissImmersiveSpace()
                }
            } catch {
                logger.error("Failed to start session: \(error)")
                await dismissImmersiveSpace()
                openWindow(id: "error")
            }
        }
        .task {
            await model.processHandUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }
        .task(priority: .low) {
            await model.processReconstructionUpdates()
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { value in
            let location3D = value.convert(value.location3D, from: .local, to: .scene)
            model.addCube(tapLocation: location3D)
        })
        .onChange(of: model.errorState) {
            openWindow(id: "error")
        }
    }
}
