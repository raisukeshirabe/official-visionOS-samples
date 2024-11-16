/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main SwiftUI view for displaying an immersive environment.
*/
import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var loader: EnvironmentLoader

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openWindow) var openWindow

    var body: some View {
        RealityView { content in
            content.add(try! await loader.getEntity())
        }.onDisappear {
            // Re-opening the window if the
            // ImmersiveSpace is closed (with the Digital Crown)
            openWindow(id: "Window")
        }
    }
}

#Preview {
    ImmersiveView(loader: .init())
        .previewLayout(.sizeThatFits)
}
