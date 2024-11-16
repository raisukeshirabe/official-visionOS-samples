/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The single entry point of the app.
*/

import SwiftUI

@main
struct ArtistWorkflowExampleApp: App {
    
    @State private var appModel = AppModel()
    
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .onChange(of: appModel.showImmersiveSpace) { _, newValue in
                    Task { @MainActor in
                        if newValue {
                            switch await openImmersiveSpace(id: "ImmersiveSpace") {
                            case .opened:
                                appModel.immersiveSpaceIsShown = true
                            case .error, .userCancelled:
                                fallthrough
                            @unknown default:
                                appModel.immersiveSpaceIsShown = false
                                appModel.showImmersiveSpace = false
                            }
                        } else if appModel.immersiveSpaceIsShown {
                            await dismissImmersiveSpace()
                        }
                    }
                }
        }.windowStyle(.plain)
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 300)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(appModel)
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
