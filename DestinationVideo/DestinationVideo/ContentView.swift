/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's top level view.
*/

import SwiftUI

/// A view that presents the app's user interface.
struct ContentView: View {
    @Environment(PlayerModel.self) private var player
    #if os(visionOS)
    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment
    #endif

    var body: some View {
        #if os(visionOS)
        Group {
            switch player.presentation {
            case .fullWindow:
                PlayerView()
                    .immersiveEnvironmentPicker {
                        ImmersiveEnvironmentPickerView()
                    }
                    .onAppear {
                        player.play()
                    }
            default:
                // Shows the app's content library by default.
                DestinationTabs()
            }
        }
        .immersionManager()
        #else
        DestinationTabs()
            .presentVideoPlayer()
        #endif
    }
}

#Preview(traits: .previewData) {
    ContentView()
}

