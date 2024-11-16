/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app structure.
*/

import OSLog
import SwiftUI

/// The entry point for the app.
@main
@MainActor
struct SceneReconstructionExampleApp: App {
    @State private var model = EntityModel()
    
    @MainActor init() {}
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        WindowGroup(id: "error") {
            Text("An error occurred; check the app's logs for details.")
        }

        ImmersiveSpace(id: cubeMeshInteractionID) {
            CubeMeshInteraction()
                .environment(model)
        }
    }
}

@MainActor
let logger = Logger(subsystem: "com.apple-samplecode.SceneReconstructionExample", category: "general")
