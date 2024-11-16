/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI

@main
struct HandTracking: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }

        // The immersive space that defines `HeadPositionView`.
        ImmersiveSpace(id: "HandTrackingScene") {
            HandTrackingView()
        }
    }
}
