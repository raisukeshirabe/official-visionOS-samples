/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The SwiftUI app structure, which acts as the app's entry point and defines the volume the app uses to display the height map mesh view.
*/

import SwiftUI

@main
struct GeneratingInteractiveGeometrySampleApp: App {
    var body: some Scene {
        WindowGroup {
            HeightMapMeshView()
        }
        #if os(visionOS)
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
        #endif
     }
}
