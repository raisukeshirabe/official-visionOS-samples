/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's entry point.
*/

import SwiftUI

@main
struct EntryPoint: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }

        // The immersive space that the app defines as a part of the scene.
        ImmersiveSpace(id: "PaintingScene") {
            PaintingView()
        }
    }
}
