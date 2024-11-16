/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays the progress while the app loads assets.
*/

import SwiftUI

/// A progress view that appears while the app loads assets.
struct StartScreenView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        HStack {
            ProgressView {
                Text("Loading assets…",
                     comment: "This lets the user know that the game can't be played yet because it is still loading assets.")
            }
        }
    }
}

#Preview(traits: .sampleAppState) {
    StartScreenView()
}
    
