/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point
*/

import SwiftUI

@main
struct EntryPoint: App {
    /// The multiplier for the height of the volumetric window.
    let heightModifier: CGFloat = 0.25

    var body: some Scene {
        // Configure a window group with a volumetric window.
        WindowGroup() {
            VolumetricWindow()
        }
        .windowStyle(.volumetric)
        // Scale the size of the window group relative to the volumetric window's size.
        .defaultSize(
            width: VolumetricWindow.defaultSize,
            height: heightModifier * VolumetricWindow.defaultSize,
            depth: VolumetricWindow.defaultSize,
            in: .meters
        )
    }
}
