/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main view.
*/

import SwiftUI

struct MainView: View {
    /// The environment value to get the `OpenImmersiveSpaceAction` instance.
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    var body: some View {
        Text("Hand Tracking Example")
            .onAppear {
                Task {
                    await openImmersiveSpace(id: "HandTrackingScene")
                }
            }
    }
}

#Preview(windowStyle: .automatic) {
    MainView()
}
