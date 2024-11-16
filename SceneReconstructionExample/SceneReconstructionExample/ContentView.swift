/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main view for the app's initial window.
*/

import SwiftUI
import RealityKit

/// The initial interface of the app.
///
/// It dismisses itself after the immersive space opens and scene reconstruction starts running.
struct ContentView: View {
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.dismiss) var dismissWindow

    var body: some View {
        Toggle("Place Cubes", isOn: $showImmersiveSpace)
            .toggleStyle(.button)
            .padding()
            .onChange(of: showImmersiveSpace) { _, shouldShowImmersiveSpace in
                Task { @MainActor in
                    if shouldShowImmersiveSpace {
                        switch await openImmersiveSpace(id: cubeMeshInteractionID) {
                        case .opened:
                            immersiveSpaceIsShown = true
                            dismissWindow()
                        case .error, .userCancelled:
                            fallthrough
                        @unknown default:
                            immersiveSpaceIsShown = false
                            showImmersiveSpace = false
                        }
                    } else if immersiveSpaceIsShown {
                        await dismissImmersiveSpace()
                        immersiveSpaceIsShown = false
                    }
                }
            }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
