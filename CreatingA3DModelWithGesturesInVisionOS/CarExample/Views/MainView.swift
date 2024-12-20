/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main view.
*/

import SwiftUI

struct MainView: View {
    /// The environment value to get the instance of the `OpenImmersiveSpaceAction` instance.
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    var body: some View {
        // Display a line of text and
        // open a new immersive space environment.
        Text("Use gestures to move the car")
            .onAppear {
                Task {
                    await openImmersiveSpace(id: "CarView")
                }
            }
    }
}

#Preview(windowStyle: .automatic) {
    MainView()
}
