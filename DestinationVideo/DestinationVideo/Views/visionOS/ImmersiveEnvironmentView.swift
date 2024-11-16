/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents an environment.
*/

import SwiftUI
import RealityKit

/// A view that presents an environment.
struct ImmersiveEnvironmentView: View {
    static let id: String = "ImmersiveEnvironmentView"

    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment

    var body: some View {
        RealityView { content in
            if let rootEntity = immersiveEnvironment.rootEntity {
                content.add(rootEntity)
            }
        }
        .onDisappear {
            immersiveEnvironment.immersiveSpaceIsShown = false
            immersiveEnvironment.showImmersiveSpace = false
            immersiveEnvironment.clearEnvironment()
        }
        .transition(.opacity)
    }
}
