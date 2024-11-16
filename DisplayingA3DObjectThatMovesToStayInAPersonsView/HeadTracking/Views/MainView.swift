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
        // Display a line of text and
        // open a new `ImmersiveSpace` environment.
        Text("Head Tracking Example")
            .onAppear {
                Task {
                    await openImmersiveSpace(id: "HeadTrackingScene")
                }
            }
    }
}

#Preview(windowStyle: .automatic) {
    MainView()
}
