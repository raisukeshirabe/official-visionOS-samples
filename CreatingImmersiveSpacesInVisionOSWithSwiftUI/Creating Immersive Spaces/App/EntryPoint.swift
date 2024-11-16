/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI

@main
struct EntryPoint: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }

        // Defines an immersive space as a part of the scene.
        ImmersiveSpace(id: "ImmersiveScene") {
            ImmersiveView()
        }
    }
}
