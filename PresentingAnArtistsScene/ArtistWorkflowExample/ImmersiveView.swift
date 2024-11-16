/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that presents the Reality Composer Pro scene.
*/

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @Environment(AppModel.self) var appModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content.
            if let immersiveContentEntity = try? await Entity(named: "ArtistWorkflowExample", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            Task { @MainActor in
                if newPhase == .background {
                    appModel.immersiveSpaceIsShown = false
                    appModel.showImmersiveSpace = false
                }
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
