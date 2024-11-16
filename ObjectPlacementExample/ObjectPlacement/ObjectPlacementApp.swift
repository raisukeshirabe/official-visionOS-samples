/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app’s entry point.
*/

import SwiftUI

private enum UIIdentifier {
    static let immersiveSpace = "Object Placement"
}

@main
@MainActor
struct ObjectPlacementApp: App {
    @State private var appState = AppState()
    @State private var modelLoader = ModelLoader()
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some SwiftUI.Scene {
        WindowGroup {
            HomeView(
                appState: appState,
                modelLoader: modelLoader,
                immersiveSpaceIdentifier: UIIdentifier.immersiveSpace
            )
                .task {
                    await modelLoader.loadObjects()
                    appState.setPlaceableObjects(modelLoader.placeableObjects)
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.plain)

        ImmersiveSpace(id: UIIdentifier.immersiveSpace) {
            ObjectPlacementRealityView(appState: appState)
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                // Leave the immersive space when the user dismisses the app.
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
    }
}
