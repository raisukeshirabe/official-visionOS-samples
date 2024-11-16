/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI

/// The app's main entry point that initializes a volumetric window and an immersive space.
@main
struct CoordSpaceTransformApp: App {
    
    /// The app's observable data model.
    @State private var appModel = AppModel()
    
    /// The action that dismisses an immersive space.
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    /// The action that presents an immersive space.
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some Scene {
        WindowGroup(id: "VolumetricView") {
            VolumetricView()
                .environment(appModel)
                .onChange(of: appModel.showImmersiveSpace) { _, newValue in
                    handleImmersiveSpaceStateChange(showImmersiveSpace: newValue)
                }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(appModel)
                .preferredSurroundingsEffect(.dark)
        }
    }
    
    /// Opens or dismisses the immersive space and sets the app model's immersive space's Boolean properties
    /// based on the user's input.
    /// - Parameter showImmersiveSpace: A Boolean value that indicates whether someone wants to show the immersive space.
    func handleImmersiveSpaceStateChange(showImmersiveSpace: Bool) {
        Task { @MainActor in
            if showImmersiveSpace {
                switch await openImmersiveSpace(id: "ImmersiveSpace") {
                case .opened:
                    appModel.immersiveSpaceIsShown = true
                case .error, .userCancelled:
                    fallthrough
                @unknown default:
                    appModel.immersiveSpaceIsShown = false
                    appModel.showImmersiveSpace = false
                }
            } else if appModel.immersiveSpaceIsShown {
                await dismissImmersiveSpace()
            }
        }
    }
}
