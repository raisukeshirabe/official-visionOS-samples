/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The content view represents the initial application view on app startup.
*/

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var enlarge = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content.

            // Register custom components and systems the app uses.
            HeroPlantComponent.registerComponent()
            HeroPlantSystem.registerSystem()
            StationaryRobotComponent.registerComponent()
            StationaryRobotSystem.registerSystem()
            HeroRobotComponent.registerComponent()
            HeroRobotSystem.registerSystem()
            EntityMoverComponent.registerComponent()
            EntityMoverSystem.registerSystem()

            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
            // Update the RealityKit content when SwiftUI state changes.
            if let scene = content.entities.first {
                let uniformScale: Float = enlarge ? 1.4 : 1.0
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            Task { @MainActor in
                if newPhase == .background {
                    appModel.showImmersiveSpace = false
                }
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack(spacing: 12) {
                    Button {
                        enlarge.toggle()
                    } label: {
                        Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)
                    
                    Button {
                        appModel.showImmersiveSpace.toggle()
                    } label: {
                        Text(appModel.showImmersiveSpace ? "Hide Immersive Space" : "Show Immersive Space")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
