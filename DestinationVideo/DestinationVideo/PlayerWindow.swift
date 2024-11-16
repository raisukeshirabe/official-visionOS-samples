/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A window that contains the video player for macOS.
*/

import SwiftUI

/// A window that contains the video player for macOS.
#if os(macOS)
struct PlayerWindow: Scene {
    /// An object that controls the video playback behavior.
    var player: PlayerModel

    var body: some Scene {
        // The macOS client presents the player view in a separate window.
        WindowGroup(id: PlayerView.identifier) {
            PlayerView()
                .environment(player)
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.reset()
                }
                // Set the minimum window size.
                .frame(minWidth: Constants.playerWindowWidth,
                       maxWidth: .infinity,
                       minHeight: Constants.playerWindowHeight,
                       maxHeight: .infinity)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                // Allow the content to extend up the the window's edge,
                // past the safe area.
                .ignoresSafeArea(edges: .top)
        }
        .defaultPosition(.center)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowIdealPlacement { proxy, context in
            let displayBounds = context.defaultDisplay.visibleRect
            let idealSize = proxy.sizeThatFits(.unspecified)

            // Calculate the content's aspect ratio.
            let aspectRatio = aspectRatio(of: idealSize)
            // Determine the change between the display's size and the content's size.
            let deltas = deltas(of: displayBounds.size, idealSize)

            // Calculate the window's zoomed size while maintaining the aspect ratio
            // of the content.
            let size = calculateZoomedSize(
                of: idealSize,
                inBounds: displayBounds,
                withAspectRatio: aspectRatio,
                andDeltas: deltas
            )

            // Position the window in the center of the display and return the
            // corresponding window placement.
            let position = position(of: size, centeredIn: displayBounds)
            return WindowPlacement(position, size: size)
        }
    }
}
#endif
