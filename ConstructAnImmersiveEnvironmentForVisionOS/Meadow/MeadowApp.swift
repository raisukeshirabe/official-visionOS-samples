/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main app class.
*/

import SwiftUI

@main
struct MeadowApp: App {

    @State var loader = EnvironmentLoader()

    var body: some Scene {
        // Window with a portal to the environment
        WindowGroup(id: "Window") {
            ContentView(loader: loader)
        }.windowStyle(.plain)

        // ImmersiveSpace showing the environment
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(loader: loader)
        }.immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
