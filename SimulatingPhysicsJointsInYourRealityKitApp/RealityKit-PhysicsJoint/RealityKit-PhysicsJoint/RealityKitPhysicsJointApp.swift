/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI

@main
struct RealityKitPhysicsJointApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        #if os(visionOS)
        .windowStyle(.volumetric)
        #endif
    }
}
