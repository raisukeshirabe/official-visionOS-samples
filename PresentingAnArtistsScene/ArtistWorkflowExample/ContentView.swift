/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The top-level view of the app.
*/

import SwiftUI
import RealityKit
import RealityKitContent

extension Image {
  init(resource name: String, ofType type: String) {
    guard let path = Bundle.main.path(forResource: name, ofType: type),
          let image = UIImage(contentsOfFile: path) else {
      self.init(name)
      return
    }
    self.init(uiImage: image)
  }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(AppModel.self) var appModel

    var body: some View {
        VStack(alignment: .trailing) {
            if appModel.immersiveSpaceIsShown {
                EmptyView()
            } else {
                Image(resource: "environment", ofType: "png")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .glassBackgroundEffect()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            Task { @MainActor in
                if newPhase == .background {
                    appModel.showImmersiveSpace = false
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack(spacing: 12) {

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

#Preview(windowStyle: .plain) {
    ContentView()
        .environment(AppModel())
}
