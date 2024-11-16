/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view containing the immersive reality view.
*/

import RealityKit
import SwiftUI

/// The view that contains the contents of the immersive space.
struct ImmersiveView: View {
    
    /// The app's observable data model.
    @Environment(AppModel.self) private var appModel
    
    /// The current scene phase used to show or hide the immersive space.
    @Environment(\.scenePhase) private var scenePhase
    
    /// The subscription to the playback completed animation event when the cube moves back to
    /// the position in the volumetric window.
    @State private var subscriptionToMoveCompleted: EventSubscription?
    
    var body: some View {
        createImmersiveSpaceRealityView()
            .gesture(appModel.dragUpdateTransforms)
            .gesture(doubleTapMove)
            .onChange(of: scenePhase, disableImmersiveSpace)
    }
    
    /// Creates the the reality for the immersive space.
    /// - Returns: The reality view for the immersive space.
    private func createImmersiveSpaceRealityView() -> some View {
        RealityView { content in
            
            // Add the root entity of the immersive space to the content.
            content.add(appModel.immersiveSpaceRootEntity)
            
            // Subscribe to the animation event when the volume cube
            // moves back to the last recorded position in the volumetric window.
            subscriptionToMoveCompleted = content.subscribe(
                to: AnimationEvents.PlaybackCompleted.self,
                on: appModel.volumeCube,
                makeCubeSubEntityOfVolumeRoot)
        }
    }

    /// Move the cube from the immersive space to the volumetric window with a double-tap gesture.
    var doubleTapMove: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                appModel.moveCubeFromImmersiveSpaceToVolumetricWindow()
            }
    }

    /// Makes the cube a subentity of the volumetric window and
    /// sets the transform value to the previously recorded transform.
    ///
    /// - Parameter event: The playback completed animation event.
    /// Note that the method doesn't use the `event` argument, but exists to conform to the expected argument in the subscription.
    private func makeCubeSubEntityOfVolumeRoot(
        _ event: AnimationEvents.PlaybackCompleted
    ) {
        
        // Make the volume cube a subentity of the volumetric window's root.
        appModel.volumeRootEntity.addChild(appModel.volumeCube)
        
        // Set the transform to the last recorded transform.
        appModel.volumeCube.transform =
            appModel.volumeCubeLastSceneTransformEntity.transform
        
        // Set the material to the volumetric material.
        appModel.volumeCube.components[ModelComponent.self]?.materials = [
            appModel.volumetricMaterial
        ]
        
        // Update the scene and immersive space transforms.
        appModel.updateTransform(relativeTo: .scene)
        appModel.updateTransform(relativeTo: .immersiveSpace)
        
        // Enable the scene transform attachment because the cube is in the
        // volumetric window.
        appModel.sceneAttachmentEntity?.isEnabled = true
        
        appModel.cubeInImmersiveSpace = false
    }
    
    /// Disables the immersive space if the app moves to the background.
    private func disableImmersiveSpace() {
        guard scenePhase == .background else { return }

        appModel.immersiveSpaceIsShown = false
        appModel.showImmersiveSpace = false
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
