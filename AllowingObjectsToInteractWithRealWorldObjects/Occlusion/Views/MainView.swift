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
       Text("World Occlusion Example")
           .onAppear {
               Task {
                   await openImmersiveSpace(id: "WorldOcclusion")
               }
           }
    }
}

#Preview(windowStyle: .automatic) {
   MainView()
}

